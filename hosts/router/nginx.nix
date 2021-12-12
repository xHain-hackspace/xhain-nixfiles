{ config, ... }:

{
  services.nginx.virtualHosts.${config.networking.fqdn}.locations."/leases" = {
    root = "/var/lib/dhcp";
    tryFiles = "/dhcpd.leases =404";
    extraConfig = ''
      default_type text/plain;
    '';
  };
}
