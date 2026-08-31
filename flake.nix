{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11-small";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kea-lease-viewer = {
      url = "github:reimerei/kea-lease-viewer/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      flakelight.builtinFormatters = false;
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
              ...
            }:
            {
              imports = [
                (./. + "/hosts/${name}/configuration.nix")
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
