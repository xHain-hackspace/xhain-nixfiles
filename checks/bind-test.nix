pkgs:
pkgs.testers.runNixOSTest {
  name = "bind service with dynamic zones";
  nodes.machine = { pkgs, ... }: {
    imports = [ ../hosts/router/dns.nix ];
    environment.systemPackages = with pkgs; [ dnsutils ];  # For `dig`
  };

  testScript = ''
  start_all()
  machine.wait_for_unit("bind.service")
  machine.succeed("dig @localhost lan.xhain.space. SOA +short")
  machine.succeed("dig @localhost hosting.xhain.space. SOA +short")
  machine.succeed("dig @localhost guest.xhain.space. SOA +short")
  '';
}
