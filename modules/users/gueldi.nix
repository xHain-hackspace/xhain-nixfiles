{ ... }:
{
  users.users.gueldi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvSWbhrIzRaCiKgBZd/AeuuIPZmRI2Ry8MtJYSyNdbs"
    ];
  };
}
