{ ... }:

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
    ];
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
