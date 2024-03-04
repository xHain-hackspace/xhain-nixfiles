{ lib, config, pkgs, ... }:

{
  imports = [
    ../../modules/nftables
    ../../modules/prometheus-iperf3-exporter
    ../../modules/secrets
    ../../modules/groups/admins.nix
    ../../modules/users/fluepke.nix
    ../../modules/users/yuka.nix
    ./local_modules
    ./hardware-configuration.nix
    ./wireguard.nix
    ./lan.nix
    ./dns.nix
    ./dhcp.nix
  ];

  boot.loader.systemd-boot.enable = true;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # boot.loader.grub.device = "/dev/sda";
  boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" "panic=1" "boot.panic_on_fail" ];

  networking.hostName = "router";
  networking.domain = "xhain.space";
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.useNetworkd = true;
  services.resolved.dnssec = "false";

  #networking.nameservers = [
  #  "2606:4700:4700::1111" "2001:4860:4860::8888" "2606:4700:4700::1001" "2001:4860:4860::8844"
  #  "1.1.1.1" "1.0.0.1"
  #];

  services.lldpd.enable = true;
  nftables.enable = true;
  services.iperf3-exporter.enable = false;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    tcpdump
    nload
    ripgrep
    nmap
    dig
  ];
  programs.mtr.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
