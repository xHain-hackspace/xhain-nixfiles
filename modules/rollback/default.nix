{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "rollback" ''
      echo "Available generations:"
      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
      echo ""

      echo -n "Enter generation number: "
      read generation

      if [ ! -e "/nix/var/nix/profiles/system-$generation-link" ]; then
        echo "Generation $generation does not exist"
        exit 1
      fi

      sudo /nix/var/nix/profiles/system-$generation-link/bin/switch-to-configuration switch
    '')
  ];
}
