pkgs:
pkgs.testers.runNixOSTest {
  name = "bind service";
  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ ../hosts/router/dns.nix ];
    };

  testScript = ''
    start_all()
    machine.wait_for_unit("bind-create-dynamic-zones.service")
    machine.wait_for_unit("bind.service")
  '';
}
