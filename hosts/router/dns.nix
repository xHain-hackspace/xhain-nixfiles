{ pkgs, lib, ... }:

with lib;

let
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
    slaves = [ "127.0.0.1" "::1" ];
    file = "/var/lib/bind/${name}zone";
    extraConfig = ''
      allow-update { key "rndc-key"; };
    '';
  };
in {
  systemd.services.bind.preStart = ''
    mkdir -p /var/lib/bind
    chown named /var/lib/bind
    ${ concatStrings (map (zone: ''
      if [[ ! -f /var/lib/bind/${zone}zone ]]; then
        cp "${templateFile}" "/var/lib/bind/${zone}zone"
      fi
      chmod 0644 "/var/lib/bind/${zone}zone"
      chown named "/var/lib/bind/${zone}zone"
    '') dynamicZones) }
  '';
  services.bind = {
    enable = true;
    cacheNetworks = [
      "127.0.0.0/8"
      "::/64"
      "192.168.42.0/23"
      "2a0f:5382:acab:1342::/64"
      "45.158.40.192/26"
      "2a0f:5382:acab:1337::/64"
      "192.168.12.0/23"
      "2a0f:5382:acab:1312::/64"
    ];
    zones = [
      {
        name = "xhain.space.";
        master = true;
        slaves = [ "127.0.0.1" "::1" ];
        file = ./xhain.space.zone;
      }
    ] ++ (map mkDynamicZone dynamicZones);
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
