{ pkgs, lib, ... }:

with lib;

let
  templateFile = pkgs.writeText "template.zone" ''
    $TTL 3600
    @               IN      SOA     ns1.xhain.space. hostmaster.x-hain.de. 2021112802 7200 900 1209600 86400
                    IN      NS      ns1.xhain.space.
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
    file = pkgs.writeText "${name}zone" (builtins.readFile templateFile);
    extraConfig = ''
      allow-update { key "rndc-key"; };
      # journal go to a writable dir (Nix store is read-only)
      journal "/var/run/named/${name}zone.jnl";
    '';
  };
in
{
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
      "10.73.243.0/24"
      "2a0f:5382:acab:1323::/64"
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
