{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11-small";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    kea-lease-viewer.url = "github:reimerei/kea-lease-viewer/main";
    kea-lease-viewer.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @inputs:
    let
      #System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ (final: prev: import ./pkgs final prev) ];
        config = { allowUnfree = true; };
      });
    in
    {
      devShell = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            git
            colmena
          ];
          name = "dots";
          DIRENV_LOG_FORMAT = "";
        });


      colmena = {
        meta = {
          nixpkgs = nixpkgsFor."x86_64-linux";
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
