{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11-small";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kea-lease-viewer = {
      url = "github:reimerei/kea-lease-viewer/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakelight.url = "github:nix-community/flakelight";
  };
  outputs = { nixpkgs, sops-nix, kea-lease-viewer, flakelight, ... }:
    flakelight ./. {
      inputs.nixpkgs = nixpkgs;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      devShell = {
        packages = pkgs: [
          pkgs.alejandra
          pkgs.git
          pkgs.colmena
        ];
        env.DIRENV_LOG_FORMAT = "";
      };
      
      outputs = {
        colmena = {
          meta = {
            nixpkgs = import nixpkgs {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
              overlays = [ (final: prev: import ./pkgs final prev) ];
            };
            specialArgs.inputs = { inherit sops-nix kea-lease-viewer; };
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
    };

}
