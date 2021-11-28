{ ... }:

{
  users.users.yuka = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzSwdjZ3t0SKet6u5Mjz0lcNFC9ZUkkfNj401kwAPx9sXK6t30tPnYt+agVfyU290JWw+bnB4Rt1MQEMWTk/oQHFlkbBHW8JH6oJc6EOKV30AIKyJXCGDWQ3u86dN6GF0EIJf7WMDtlgKceY+NZprKkaXrmSUrreMiQc9fpEIWZa5+jPRLveHE1Z2yHEtf1zDNM1j0v1e3bje8xL50arDa0ZjSz00Skh3qJCMH8aAW1McgAGWa8FfwytTuByvpKh0Czk9Za3eAHTVDGVrNwBu0lDFEqYdxnv7lZvJiTrkG+9IFHUsbngQYEvOD8LW3WN/LKE3ErxhHSxRfPm/VIjcTZO3FEA2D0EdbXhyqTuhhysOg13ssrcjXfwWjIY+zdfBOgmaGttcd8gtl20YuXPbqbdqzEDZsDUFFre8Ef6w9ZTT98vabXPGsB7nWU5P3qfgU6dh5SE17AoT9/PnkcPUftHVtov5ToyNsRGclLcyCvfs+rA1AsbLjW7wpQ191ZDoGDT8bMDGheCaHGOlNFnCSZkbB5S8o6gynMJfiviCWR4MiH47oFD/n2z0i+5AafMWv5ZUWr1A0HycP8k6hr7Zc+JPMK9kun9hopVaWHA6lLMg92VDG1eeNCxK7Dv8v23PA5gTugbQvyfcwSECj3hPpzCEsCnyvFoF3BZkvDpJGeQ== yuka"
    ];
  };
  users.users.fluepke = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnttbPs5sT2VdrmN7AOAb8hdUcqCNg3/btI+bl/eUB0OaGMELhOYam7YM560PJ/tpMN2M1K1OKdIxBjn4lFmNyWYLCvgWuDyNn7Zp/oUIe9j0d+GzdYHg43mRVXU0FHnvzFum43fuxb4OsEkXcWkrNME9rwzv2dEk4NPtUhtpBEtCqOTUCG7L9mUCNBg6+dCcZ5ue2xic5ARla0FGF67vOgZEp02y9MR27uXS3ZjX74lvhDc/nG/VVh793bVve0sqNVuay57xA2aGxhbnpQYN1CioMv25lgC8a3o4rS+yl/73vT1c/ZiBi4zW24l3rtH6cmo4p9jOWwWF062NXGBUXL4J6bmu+wbAlA7SCJ2BjyZVU8zVumh/XV51DUygz6K4RBP0FhvnNLbdFwu/ecM+lRsu3hTIODNnrDQ+iQ8m1G+e5hmvAqK1+pU7R2CLKB01sVnpg5PyeMNLIuLgujEH5OhzsunDRj48vrCYLq1CUr3iacJYyGL/u4CUyRApHdQc="
    ];
  };
  users.users.danimo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRmYBlEPuch0aHgvH6gM1M+q2p6AgXnrwbQw1BVBt1Tec0g2NOTqJSaSXrmr6X4wylw5hdKbRdtmrGucgeTPHoHf4bQ7NmSU6s6+GjzvlAFZNK/TWW+YNDP3AfFsBvoZ0G+HUCpGwEL+6c56/uMP2gDoibPAzUclDmR14J6Oyo+7t9z7KPMvsq8kDyaHUAkgCCoprB48oWWXk0aQUE/l1O+1RlV6SJCrREtGBdmU3Wytq9oarkar+QtKEOBo4utNG8SZ5bZR5I1SGFEApGJLSlGewWx4sKlh7V7t/Pe0O+UhFbB5zj97f2rbBc8eXTKO3jFacqHTIG/Voy/fH7hFY2GGknCXtEPNuPLTb8dWKVU5W8BxmEC2lJtGK72tNYHa985ZMkjZEL5eBsMk+N6UsbnticY6daiMYqTnlXJuN6QGt/ZR5agJ6t/ohmsOYZcImFKDnrZCNBSv271kdEuPIxmn0weoh2P468w0vTHVUhuosoYB1t0EU7vMm/H8hwyqC9HE8MQsxQhVYj7d9Hr6E0znWSGs7lw2vl2nHBb5+QZ7i6/F50zDteNYIoOTTf6v3b4oHn7VlmcfKRZxR948jQX6oENydxEYkojc2aVWDkVBNYW9wmQx9EDNcAJ7NEBpxZY3/Cqip3UvX4e/fagsjwf2fVbUc5rAJ4zdLv0HidFQ=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmT64p9bY5pLctzOCdqyzI3tsoGdVqay55Lrpo52zL4u4E9xsaCC5+nmfzyIWWX/wyI63c544b32BSRoi/092A+gLjLDWPr6jGb+4fFamJKSi9YxrOEGpV8u84ZXniex0+nmXAm7UmUp9lQo0hpdZ4Gt6nn8IQ2yFJ+80vsJ19oOaZzQM0K+g7XHWYyS2D7rOTG/FAqNV10CzxBu78lgrwAvz8eOeNm11bETIVIJbhwGjaDcJyY5AeifncetHdI712IJeEftyMz6jEsMlCtm36rxPnAiSGtSnCLdvbqIt5zg05nwd/gGPTUc6mtK8viufALu1JCrEDGQGtdROYmOQJiwzUpNPxhWfq+RJccFUdfzzSAit/fr58LRIKU7FlNyJ8XvILJaigndhnFDpocBLOttiDyz8uK1yXBZBPgw+LvqklBLyioCGhsGCs5i7KFMXGCGlklf8HSONAVRUhwaGfta1hn83+/WdtjWCygQgU9/1nhKi8gc9yB2ZfAi8xFDnHXngVY38PwaHIhV4VxlO6RNI1RLK4783QXN8a0X1hujNsJxokfPyWhsoWPqnv2QhxSHcEAK2DjGc4wkUkPs3L+6kHAx/weYstNtZDU7tUlvLUOm8w5DAcFkRhmh7j6aR4js1vYMLwI5PqtUzlXXK/SIkwa+GMvzsPFxJAM1FnEQ=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvSWbhrIzRaCiKgBZd/AeuuIPZmRI2Ry8MtJYSyNdbs"
    ];
  };
  users.users.reimerei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV"
    ];
  };
}
