{ ... }:

{
  users.users.fluepke = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBA44xH1sDtmDSZ8GFdzwqG7GFCIi3xZQ0QoR6Q6Oj9abBl6uUXuI7ia6yiQLImC1MPNpUVyzSHVrIMjXUkJEBz0="
    ];
  };
}
