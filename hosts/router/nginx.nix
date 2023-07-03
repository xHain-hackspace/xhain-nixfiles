{ config, pkgs, ... }:

let 
  luaFile = pkgs.copyPathToStore ./render-dhcp-leases.lua;
in {
  # services.nginx.additionalModules = with pkgs.nginxModules; [
  #   lua
  # ];

  # fileSystems."/var/lib/dhcp" = {
  #   device = "/var/lib/dhcpd4";
  #   options = ["bind" "ro" "X-mount.mkdir" "user" "noauto"];
  #   fsType = "none";
  # };

  # services.nginx.virtualHosts.${config.networking.fqdn}.locations."/leases" = {
  #   extraConfig = ''
  #     default_type text/html;
  #     content_by_lua_file ${luaFile};
  #   '';
  # };
}

