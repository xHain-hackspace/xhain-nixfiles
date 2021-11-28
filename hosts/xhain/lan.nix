{ ... }:

{
  systemd.network.networks = {
    "40-intern".networkConfig.ConfigureWithoutCarrier = true;
    "40-hosting".networkConfig.ConfigureWithoutCarrier = true;
    "40-guest".networkConfig.ConfigureWithoutCarrier = true;
  };

  networking.vlans.intern  = { interface = "enp4s0"; id = 42; };
  networking.vlans.hosting = { interface = "enp4s0"; id = 37; };
  networking.vlans.guest   = { interface = "enp4s0"; id = 12; };

  networking.interfaces.intern = {
    ipv4.addresses = [
      { address = "192.168.42.0"; prefixLength = 23; }
    ];
    ipv6.addresses = [
      { address = "2a0f:5382:acab:1342::1"; prefixLength = 64; }
    ];
  };
  networking.interfaces.hosting = {
    ipv4.addresses = [
      { address = "45.158.40.193"; prefixLength = 26; }
    ];
    ipv6.addresses = [
      { address = "2a0f:5382:acab:1337::1"; prefixLength = 64; }
    ];
  };
  networking.interfaces.guest = {
    ipv4.addresses = [
      { address = "192.168.12.0"; prefixLength = 23; }
    ];
    ipv6.addresses = [
      { address = "2a0f:5382:acab:1312::1"; prefixLength = 64; }
    ];
  };

  services.radvd = {
    enable = true;
    config = ''
      interface intern {
        AdvSendAdvert on;
        prefix 2a0f:5382:acab:1342::/64 {
          AdvRouterAddr on;
        };
        RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {};
      };
      interface hosting {
        AdvSendAdvert on;
        prefix 2a0f:5382:acab:1337::/64 {
          AdvRouterAddr on;
        };
        RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {};
      };
      interface guest {
        AdvSendAdvert on;
        prefix 2a0f:5382:acab:1312::/64 {
          AdvRouterAddr on;
        };
        RDNSS 2606:4700:4700::1111 2606:4700:4700::1001 {};
      };
    '';
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "intern" ];
    extraConfig = ''
      subnet 192.168.42.0 netmask 255.255.254.0 {
        range 192.168.42.20 192.168.43.254;
        option domain-name-servers 1.1.1.1;
        option routers 192.168.42.1;
        interface intern;
      }
      subnet 45.158.40.192 netmask 255.255.255.192 {
        range 45.158.40.201 45.158.40.254;
        option domain-name-servers 1.1.1.1;
        option routers 45.158.40.193;
        interface hosting;
      }
      subnet 192.168.12.0 netmask 255.255.254.0 {
        range 192.168.12.20 192.168.13.254;
        option domain-name-servers 1.1.1.1;
        option routers 192.168.12.1;
        interface guest;
      }
    '';
  };

  nftables = let
    mtuFix = ''
      meta nfproto ipv6 tcp flags syn tcp option maxseg size 1305-65535 tcp option maxseg size set 1304
      meta nfproto ipv4 tcp flags syn tcp option maxseg size 1325-65535 tcp option maxseg size set 1324
    '';
  in {
    forwardPolicy = "accept";
    extraInput = mtuFix + ''
      iifname { intern, hosting, guest } icmpv6 type nd-router-solicit accept
    '';
    extraOutput = mtuFix;
    extraForward = mtuFix + ''
      ct state invalid drop
      ct state established,related accept

      oifname { intern, guest } icmpv6 type { packet-too-big, echo-request, echo-reply, mld-listener-query, mld-listener-report, mld-listener-done, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
      oifname { intern, guest } icmp type echo-request accept
      oifname { intern, guest } drop
    '';
    extraConfig = ''
      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100
          # masquerade private IP addresses
          iifname { intern, guest } snat to 45.158.40.192;
        }
      }
    '';
  };

  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;
}
