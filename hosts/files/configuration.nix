{ config, pkgs, name, ... }:

{
  imports = [
    ../../modules/proxmox_server
  ];

  networking.hostName = name;

  environment.systemPackages = with pkgs; [
  ];

  users.groups.samba = { };

  system.activationScripts.permissions = ''
    chown root:samba /media/storage
    chmod g+wx /media/storage
  '';

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";

    extraConfig = ''
      server string = Files
      map to guest = Bad User
      passdb backend = tdbsam
      force group = samba
    '';
    shares = {
      Storage = {
        comment = "Storage";
        path = "/media/storage";
        browseable = true;
        "read only" = false;
        "guest ok" = true;

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
      };
    };
  };

}
