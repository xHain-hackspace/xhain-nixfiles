{ ... }:

{
  users.users.fluepke = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnttbPs5sT2VdrmN7AOAb8hdUcqCNg3/btI+bl/eUB0OaGMELhOYam7YM560PJ/tpMN2M1K1OKdIxBjn4lFmNyWYLCvgWuDyNn7Zp/oUIe9j0d+GzdYHg43mRVXU0FHnvzFum43fuxb4OsEkXcWkrNME9rwzv2dEk4NPtUhtpBEtCqOTUCG7L9mUCNBg6+dCcZ5ue2xic5ARla0FGF67vOgZEp02y9MR27uXS3ZjX74lvhDc/nG/VVh793bVve0sqNVuay57xA2aGxhbnpQYN1CioMv25lgC8a3o4rS+yl/73vT1c/ZiBi4zW24l3rtH6cmo4p9jOWwWF062NXGBUXL4J6bmu+wbAlA7SCJ2BjyZVU8zVumh/XV51DUygz6K4RBP0FhvnNLbdFwu/ecM+lRsu3hTIODNnrDQ+iQ8m1G+e5hmvAqK1+pU7R2CLKB01sVnpg5PyeMNLIuLgujEH5OhzsunDRj48vrCYLq1CUr3iacJYyGL/u4CUyRApHdQc="
    ];
  };
}
