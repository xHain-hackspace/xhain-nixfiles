{ ... }:

{
  users.users.yuka = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzSwdjZ3t0SKet6u5Mjz0lcNFC9ZUkkfNj401kwAPx9sXK6t30tPnYt+agVfyU290JWw+bnB4Rt1MQEMWTk/oQHFlkbBHW8JH6oJc6EOKV30AIKyJXCGDWQ3u86dN6GF0EIJf7WMDtlgKceY+NZprKkaXrmSUrreMiQc9fpEIWZa5+jPRLveHE1Z2yHEtf1zDNM1j0v1e3bje8xL50arDa0ZjSz00Skh3qJCMH8aAW1McgAGWa8FfwytTuByvpKh0Czk9Za3eAHTVDGVrNwBu0lDFEqYdxnv7lZvJiTrkG+9IFHUsbngQYEvOD8LW3WN/LKE3ErxhHSxRfPm/VIjcTZO3FEA2D0EdbXhyqTuhhysOg13ssrcjXfwWjIY+zdfBOgmaGttcd8gtl20YuXPbqbdqzEDZsDUFFre8Ef6w9ZTT98vabXPGsB7nWU5P3qfgU6dh5SE17AoT9/PnkcPUftHVtov5ToyNsRGclLcyCvfs+rA1AsbLjW7wpQ191ZDoGDT8bMDGheCaHGOlNFnCSZkbB5S8o6gynMJfiviCWR4MiH47oFD/n2z0i+5AafMWv5ZUWr1A0HycP8k6hr7Zc+JPMK9kun9hopVaWHA6lLMg92VDG1eeNCxK7Dv8v23PA5gTugbQvyfcwSECj3hPpzCEsCnyvFoF3BZkvDpJGeQ== yuka"
    ];
  };
}
