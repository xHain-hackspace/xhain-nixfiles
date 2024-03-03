{ config, pkgs, lib, name, inputs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    inputs.sops-nix.nixosModules.sops
    ./users.nix
  ];

  proxmoxLXC.manageHostName = lib.mkDefault true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  security = {
    sudo.wheelNeedsPassword = false;
    pam.enableSSHAgentAuth = true;
  };

  nix.gc.automatic = true;
  nix.gc.dates = lib.mkDefault "weekly";

  nix.settings.trusted-users = [ "root" "@wheel" ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];

    defaultLocale = "en_US.UTF-8";
  };

  users.mutableUsers = false;
  hardware.enableAllFirmware = true;
  system.autoUpgrade.enable = false;

  system.stateVersion = "23.11";
}
