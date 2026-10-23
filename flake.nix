{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05-small/nixexprs.tar.zst";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kea-lease-viewer = {
      url = "github:reimerei/kea-lease-viewer/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    flakelight.url = "github:nix-community/flakelight";
    flakelight.inputs.nixpkgs.follows = "nixpkgs";
    flakelight-treefmt.url = "github:m15a/flakelight-treefmt";
    flakelight-treefmt.inputs.flakelight.follows = "flakelight";
  };
  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      kea-lease-viewer,
      flakelight,
      nix-index-database,
      ...
    }@inputs:
    flakelight ./. {
      inputs.self = self;
      inputs.nixpkgs = nixpkgs;
      imports = [ inputs.flakelight-treefmt.flakelightModules.default ];
      treefmtConfig = {
        programs.nixfmt.enable = true;
        programs.terraform.enable = true;
        settings.global.excludes = [ "terraform/secrets.tfvars" ];
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      devShell = {
        packages = pkgs: [
          pkgs.alejandra
          pkgs.git
          pkgs.colmena
          pkgs.sops
          pkgs.opentofu
          # pkgs.prometheus-snmp-exporter
        ];
        env.DIRENV_LOG_FORMAT = "";
      };

      checks = import ./checks inputs;

      outputs = {
        colmena = {
          meta = {
            nixpkgs = import nixpkgs {
              system = "x86_64-linux";
              config = {
                allowUnfree = true;
              };
              overlays = [ (final: prev: import ./pkgs final prev) ];
            };
            specialArgs.inputs = { inherit sops-nix kea-lease-viewer; };
          };

          defaults =
            {
              config,
              lib,
              name,
              pkgs,
              ...
            }:
            {
              imports = [
                (./. + "/hosts/${name}/configuration.nix")
                nix-index-database.nixosModules.default
                {
                  programs.nix-index.package =
                    nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-small-db;
                  programs.nix-index-database.comma.enable = true;
                }
              ];
              deployment.targetHost = lib.mkDefault "${name}.lan.xhain.space";
              deployment.targetUser = null;
            };

          router =
            { ... }:
            {
              deployment.targetHost = "router.xhain.space";
              imports = [
                kea-lease-viewer.nixosModules.default
              ];
            };

          files =
            { ... }:
            {
              deployment.targetHost = "files.xhain.space";
            };

          nix-builder = { ... }: { };
        };
      };
    };

}
