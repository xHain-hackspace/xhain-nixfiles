{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/77d0269595488cf2fae06c5a8c3f63ebc94e7f13";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, sops-nix, ... }: {
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
          sops-nix.nixosModules.sops
        ];
        deployment.targetHost = lib.mkDefault "${name}.xhain.space";
      };

      router = {...}: {
      };
    };
  };
}
