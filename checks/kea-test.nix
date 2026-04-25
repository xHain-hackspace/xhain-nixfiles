inputs: pkgs:
pkgs.testers.runNixOSTest {
  name = "kea service";
  nodes.machine =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.kea-lease-viewer.nixosModules.default
        ../modules/secrets
        ../hosts/router/dhcp.nix
      ];

      secrets.kea-ddns-key = {
        enable = true;
        encrypted = false;
        source-path =
          (pkgs.writeText "kea-ddns-key.gpg" (
            builtins.toJSON {
              name = "rndc-key";
              algorithm = "hmac-sha256";
              # "test-secret-key-for-testing"
              secret = "dGVzdC1zZWNyZXQta2V5LWZvci10ZXN0aW5n";
            }
          )).outPath;
      };

      # Use available interfaces for testing (production uses voc, intern, hosting, guest)
      services.kea.dhcp4.settings.interfaces-config = lib.mkForce {
        interfaces = [ "eth0" ];
      };
    };

  testScript = ''
    start_all()
    machine.wait_for_unit("kea-dhcp4-server.service")
  '';
}
