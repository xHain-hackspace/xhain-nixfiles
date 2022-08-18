let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in {
  deploy = import ./lib/deploy.nix { inherit pkgs; };
}
