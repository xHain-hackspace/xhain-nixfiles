{ config, pkgs, name, ... }:

{
  imports = [
    ../../modules/proxmox_server
  ];

  networking.hostName = name;

  environment.systemPackages = with pkgs; [
    niv
    colmena
  ];

  nix.settings.trusted-users = [ "builder" ];

  users.users.builder = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV reimerei@silence"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK8wISQGiy6weaMg4tFiMHXlK71iHGoZkpfJQVNC4Up root@silence"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvSWbhrIzRaCiKgBZd/AeuuIPZmRI2Ry8MtJYSyNdbs danimo"
    ];
  };

  nix.gc.dates = "quarterly";
}
