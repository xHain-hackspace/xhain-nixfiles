pkgs:
pkgs.testers.runNixOSTest {
  name = "bind service with dynamic zones";
  nodes.machine = { pkgs, ... }: {
    imports = [ ../hosts/router/dns.nix ];
    environment.systemPackages = with pkgs; [ dnsutils ]; # For `dig`
  };

  testScript = ''
    start_all()
    machine.wait_for_unit("bind.service")
    machine.succeed("dig @localhost lan.xhain.space. SOA +short")
    machine.succeed("dig @localhost hosting.xhain.space. SOA +short")
    machine.succeed("dig @localhost guest.xhain.space. SOA +short")
    machine.succeed("dig @localhost 192-255.40.158.45.in-addr.arpa. SOA +short")
    machine.succeed("dig @localhost f.f.f.f.7.8.3.5.f.0.a.2.ip6.arpa. SOA +short")
    machine.wait_until_succeeds(
      "dig @localhost 192-255.40.158.45.in-addr.arpa. DNSKEY +short | grep -q ."
    )
    machine.wait_until_succeeds(
      "dig @localhost f.f.f.f.7.8.3.5.f.0.a.2.ip6.arpa. DNSKEY +short | grep -q ."
    )
    machine.succeed("find /var/lib/bind -maxdepth 1 -name 'K*.private' | grep -q .")
  '';
}
