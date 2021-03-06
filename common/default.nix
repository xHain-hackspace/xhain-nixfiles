{ lib, config, pkgs, ... }:

{
  imports = [
    ./users.nix
    ./nginx
    ./snmp
    ./prometheus
    ../modules
  ];

  boot.kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_latest;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.challengeResponseAuthentication = false;
  services.openssh.permitRootLogin = lib.mkDefault "no";
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";
  security.sudo.wheelNeedsPassword = false;

  nix.gc.automatic = lib.mkDefault true;
  nix.trustedUsers = [ "root" "@wheel" ];

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
