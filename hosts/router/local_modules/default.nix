{ lib, config, pkgs, ... }:

{
  imports = [
    ./nginx
    ./snmp
    ./prometheus
  ];

  nixpkgs.config.packageOverrides = import ../../../pkgs { inherit pkgs lib; };

  boot.kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_latest;

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = lib.mkDefault "no";
    # CVE-2024-6387
    # https://github.com/NixOS/nixpkgs/pull/323753#issuecomment-2199762128
    LoginGraceTime = 0;
  };

  services.openssh.extraConfig = "StreamLocalBindUnlink yes";
  security.sudo.wheelNeedsPassword = false;

  nix.gc.automatic = lib.mkDefault true;
  nix.settings.trusted-users = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [
    htop
    vim
    tmux
    gnupg
    wget
    rsync
  ];

  environment.variables = {
    EDITOR = "vim"; # fight me :-)
  };

  users.defaultUserShell = pkgs.zsh; # fight me :p
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ ];
      theme = "risto";
    };
  };

  programs.zsh.shellAliases = {
    ".." = "cd ..";
    use = "nix-shell -p";
    ll = "ls -l";
    la = "ls -la";
    ip = "ip -c";
  };

  system.stateVersion = "21.05"; # Did you read the comment?
}
