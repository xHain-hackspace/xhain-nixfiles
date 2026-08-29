{...}: {
  users.users.basti79 = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqeMYu/zsNCX/TsGXWtzRjoOhtWZITgCUxfj8kFziRI"
    ];
  };
}
