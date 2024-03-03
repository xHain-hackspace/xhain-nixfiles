{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11-small";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @inputs: {
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
          config = { allowUnfree = true; };
          overlays = [ (final: prev: import ./pkgs final prev) ];
        };
        specialArgs = { inherit inputs; };
      };

      defaults = { config, lib, name, ... }: {
        imports = [
          (./. + "/hosts/${name}/configuration.nix")
        ];
        deployment.targetHost = lib.mkDefault "${name}.lan.xhain.space";
        deployment.targetUser = null;
      };

      router = { ... }: {
        deployment.targetHost = "router.xhain.space";
      };

      files = { ... }: {
        deployment.targetHost = "files.xhain.space";
      };

      nix-builder = { ... }: { };
    };
  };
}
