{ ... }:

{
  users.users.lenny = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeeWp/a1PJAL1xhOU/gozb+zdWBHFVbQEBCSlPIByFd"
    ];
  };
}
