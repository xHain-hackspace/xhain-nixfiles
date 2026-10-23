{
  config,
  options,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.xhain.dns;
  acmeKeyName = host: "acme-${host}";
  acmeSecretName = host: "bind-${acmeKeyName host}";
  hostsInZone = zone: filter (host: hasSuffix ".${zone}" "${host}.") cfg.acmeHosts;
  templateFile = pkgs.writeText "template.zone" ''
    $TTL 3600
    @               IN      SOA        ns1.xhain.space. hostmaster.x-hain.de. 2021112802 7200 900 1209600 86400
                    IN      NS         ns1.xhain.space.
  '';
  dynamicZones = [
    "lan.xhain.space."
    "hosting.xhain.space."
    "guest.xhain.space."
  ];
  mkDynamicZone = name: {
    inherit name;
    master = true;
    slaves = [
      "127.0.0.1"
      "::1"
    ];
    file = "/var/lib/bind/${name}zone";
    extraConfig = ''
      ${
        if hostsInZone name != [ ] then
          ''
            update-policy {
              grant rndc-key zonesub ANY;
              ${concatMapStringsSep "\n" (
                host: "grant ${acmeKeyName host} name _acme-challenge.${host}. TXT;"
              ) (hostsInZone name)}
            };
          ''
        else
          ''allow-update { key "rndc-key"; };''
      }
      journal "/var/run/named/${name}zone.jnl";
    '';
  };
  # TODO: remove me once patch hits our channel
  patched-bind = pkgs.bind.overrideAttrs (_: rec {
    version = "9.20.30";
    src = pkgs.fetchurl {
      url = "https://downloads.isc.org/isc/bind9/${version}/bind-${version}.tar.xz";
      hash = "sha256-nhRDpApyowJyy8MZbQIKay4mk3ERyD5Z4QHoLh47T+8=";
    };
  });
in
{
  options.xhain.dns.acmeHosts = mkOption {
    type = types.listOf types.str;
    default = [ ];
    example = [ "foo.lan.xhain.space" ];
    description = ''
      Hostnames (without trailing dot) in a dynamic zone that may set
      _acme-challenge TXT records (ACME DNS-01), each with its own TSIG key.
      The sops secret "bind-acme-<host>" must contain
      `key "acme-<host>" { algorithm hmac-sha256; secret "..."; };`
    '';
  };

  config = mkMerge [
    # sops-nix isn't loaded in the bind VM test
    (optionalAttrs (options ? sops) {
      sops.secrets = listToAttrs (
        map (host: nameValuePair (acmeSecretName host) { owner = "named"; }) cfg.acmeHosts
      );
    })
    {
      assertions = map (host: {
        assertion = any (zone: hasSuffix ".${zone}" "${host}.") dynamicZones;
        message = "xhain.dns.acmeHosts: ${host} is not in a dynamic zone";
      }) cfg.acmeHosts;

      services.bind.extraConfig = concatMapStrings (host: ''
        include "${config.sops.secrets.${acmeSecretName host}.path}";
      '') cfg.acmeHosts;

      systemd.services."bind-create-dynamic-zones" = {
        before = [ "bind.service" ];
        wantedBy = [ "bind.service" ];
        script = ''
          mkdir -p /var/lib/bind
          chown named /var/lib/bind
            ${concatStrings (
              map (zone: ''
                if [[ ! -f /var/lib/bind/${zone}zone ]]; then
                  cp "${templateFile}" "/var/lib/bind/${zone}zone"
                fi
                chmod 0644 "/var/lib/bind/${zone}zone"
                chown named "/var/lib/bind/${zone}zone"
              '') dynamicZones
            )}
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;
        };
      };

      services.bind = {
        enable = true;
        package = patched-bind;
        # our startup generated config files can't
        # by checked by https://github.com/NixOS/nixpkgs/pull/501959
        checkConfig = false;
        cacheNetworks = [
          "127.0.0.0/8"
          "::/64"
          "192.168.42.0/23"
          "2a0f:5382:acab:1342::/64"
          "45.158.40.192/26"
          "2a0f:5382:acab:1337::/64"
          "192.168.12.0/23"
          "2a0f:5382:acab:1312::/64"
          "10.73.243.0/24"
          "2a0f:5382:acab:1323::/64"
        ];
        zones = [
          {
            name = "xhain.space.";
            master = true;
            slaves = [
              "127.0.0.1"
              "::1"
            ];
            file = ./xhain.space.zone;
          }
        ]
        ++ (map mkDynamicZone dynamicZones);
      };

      networking.firewall.allowedUDPPorts = [ 53 ];
      networking.firewall.allowedTCPPorts = [ 53 ];
    }
  ];
}
