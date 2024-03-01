{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11-small";
  };
  outputs = { nixpkgs, ... }: {
    devShells.default = nixpkgs.mkShell {
      packages = [
        nixpkgs.alejandra
        nixpkgs.git
        nixpkgs.colmena
      ];
      name = "dots";
      DIRENV_LOG_FORMAT = "";
    };
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ (final: prev: import ./pkgs final prev) ];
        };
      };

      defaults = { config, lib, name, ... }: {
        imports = [
          (./. + "/hosts/${name}/configuration.nix")
          ./modules
          #./common
        ];
        deployment.targetHost = lib.mkDefault "${name}.xhain.space";
        deployment.targetUser = null;
      };

      router = { ... }: { };
    };
  };
}
