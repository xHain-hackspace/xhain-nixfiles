{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.fluepke.deploy;

in {
  options = {
    fluepke.deploy = {

      ssh.host = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.${config.networking.domain}";
      };

      ssh.port = mkOption {
        type = types.int;
        default = head config.services.openssh.ports;
      };

      groups = mkOption {
        type = with types; listOf str;
        default = [];
      };

      fqdn = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.${config.networking.domain}";
      };
    };

  };

  config = {
    fluepke.deploy.groups = [ "all" ];

    system.build.deployScript = pkgs.writeScript "deploy-${config.networking.hostName}" ''
      #!${pkgs.runtimeShell}
      set -xeo pipefail
      export PATH=${with pkgs; lib.makeBinPath [ coreutils openssh nix ]}
      export NIX_SSHOPTS="$NIX_SSHOPTS -p${toString cfg.ssh.port}"
      nix copy --no-check-sigs --to ssh://${cfg.ssh.host} ${config.system.build.toplevel} --extra-experimental-features nix-command
      ssh $NIX_SSHOPTS ${cfg.ssh.host} "sudo nix-env -p /nix/var/nix/profiles/system -i ${config.system.build.toplevel}" 
      ssh $NIX_SSHOPTS ${cfg.ssh.host} "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration $1" 
    '';
  };
}
