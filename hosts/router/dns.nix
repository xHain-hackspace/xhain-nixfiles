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
  ipv4ReverseZone = "192-255.40.158.45.in-addr.arpa.";
  ipv6ReverseZone = "f.f.f.f.7.8.3.5.f.0.a.2.ip6.arpa.";
  acmeKeyName = host: "acme-${host}";
  acmeSecretName = host: "bind-${acmeKeyName host}";
  hostsInZone = zone: filter (host: hasSuffix ".${zone}" "${host}.") cfg.acmeHosts;
  templateFile =
    zone:
    pkgs.writeText "template-${zone}zone" ''
      $TTL 3600
      @ IN SOA ns1.xhain.space. hostmaster.x-hain.de. 2026110901 7200 900 1209600 3600
      @ IN NS ns1.xhain.space.
      ${optionalString (zone == ipv4ReverseZone) ''
        192 IN PTR router.xhain.space.
        193 IN PTR router-hosting.xhain.space.
      ''}
      ${optionalString (zone == ipv6ReverseZone) ''
        1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.4.3.1 IN PTR router.xhain.space.
        1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.7.3.3.1 IN PTR router-hosting.xhain.space.
        1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.1.3.1 IN PTR router-guest.xhain.space.
        1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.3.2.3.1 IN PTR router-voc.xhain.space.
      ''}
    '';
  forwardDynamicZones = [
    "lan.xhain.space."
    "hosting.xhain.space."
    "guest.xhain.space."
  ];
  reverseDynamicZones = [
    ipv4ReverseZone
    ipv6ReverseZone
  ];
  dynamicZones = forwardDynamicZones ++ reverseDynamicZones;
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
        if elem name reverseDynamicZones then
          ""
        else if hostsInZone name != [ ] then
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
      ${optionalString (elem name reverseDynamicZones) ''
        dnssec-policy default;
      ''}
      journal "/var/run/named/${name}zone.jnl";
    '';
  };
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
        assertion = any (zone: hasSuffix ".${zone}" "${host}.") forwardDynamicZones;
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
                  cp "${templateFile zone}" "/var/lib/bind/${zone}zone"
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
        # our startup generated config files can't
        # by checked by https://github.com/NixOS/nixpkgs/pull/501959
        checkConfig = false;
        cacheNetworks = [
          "127.0.0.0/8"
          "::/64"
          "192.168.42.0/23"
          "45.158.40.192/26"
          "192.168.12.0/23"
          "10.73.243.0/24"
          "2a0f:5387:ffff::/48"
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
