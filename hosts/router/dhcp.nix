{ pkgs, lib, ... }:

let
  subnets = {
    lan = {
      id = 1;
      subnet = "192.168.42.0/23";
      router = "192.168.42.1";
      dhcp_range = "192.168.42.30 - 192.168.43.254";
      ddns_domain = "lan.xhain.space.";
    };
    hosting = {
      id = 2;
      subnet = "45.158.40.192/26";
      router = "45.158.40.193";
      dhcp_range = "45.158.40.201 - 45.158.40.254";
      ddns_domain = "hosting.xhain.space.";
    };
    guest = {
      id = 3;
      subnet = "192.168.12.0/23";
      router = "192.168.12.1";
      dhcp_range = "192.168.12.30 - 192.168.13.254";
      ddns_domain = "guest.xhain.space.";
    };
    voc = {
      id = 4;
      subnet = "10.73.243.0/24";
      router = "10.73.243.1";
      dhcp_range = "10.73.243.20 - 10.73.243.254";
      ddns_domain = "lan.c3voc.de.";
    };
  };

  mkKeaSubnet = name: attrs: {
    id = attrs.id;
    subnet = attrs.subnet;
    pools = [{ pool = attrs.dhcp_range; }];
    ddns-qualifying-suffix = attrs.ddns_domain;
    option-data = [
      {
        name = "routers";
        data = attrs.router;
      }
      {
        name = "domain-name-servers";
        data = attrs.router;
      }
      {
        name = "domain-name";
        data = attrs.ddns_domain;
      }
      {
        name = "domain-search";
        data = attrs.ddns_domain;
      }
    ];
  };
  mkKeaDdnsDomains = name: attrs:
    ''{
        "dns-servers": [{"ip-address": "127.0.0.1"}],
        "key-name": "ddns",
        "name": "${attrs.ddns_domain}"
      }'';
in
{
  services.kea = {
    dhcp4 = {
      enable = true;

      settings = {
        valid-lifetime = 120;
        renew-timer = 60;
        rebind-timer = 180;

        interfaces-config = {
          interfaces = [ "voc" "intern" "hosting" "guest" ];
        };

        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
        };

        dhcp-ddns = {
          enable-updates = true;
        };
        ddns-override-client-update = true;
        ddns-override-no-update = true;
        ddns-update-on-renew = true; # disable this to improve performance

        hostname-char-set = "[^A-Za-z0-9.-]";
        hostname-char-replacement = "-";

        subnet4 = lib.mapAttrsToList mkKeaSubnet subnets;

        loggers = [
          {
            name = "kea-dhcp4";
            output_options = [
              {
                output = "stdout";
              }
            ];
            severity = "DEBUG";
            debuglevel = 0;
          }
        ];
      };
    };

    dhcp-ddns = {
      enable = true;
      # we can't use settings, because we need to embed the secret
      configFile = pkgs.writeText "ddns.conf" ''
        {
          "DhcpDdns": {
            "forward-ddns": {
              "ddns-domains": [
                ${lib.concatStringsSep ",\n" (lib.mapAttrsToList mkKeaDdnsDomains subnets)}
              ]
            },
            "tsig-keys": [
              <?include "/etc/bind/rndc.key"?>
            ],
            "loggers": [
              {
                "name": "kea-dhcp-ddns",
                "output_options": [
                    {
                        "output": "stdout",
                        "pattern": "%-5p %m\n"
                    }
                ],
                "severity": "DEBUG",
                "debuglevel": 0
              }
            ]
          }
        }
      '';
    };
  };

  # services.dhcpd4 = {
  #   enable = true;
  #   interfaces = [ "intern" ];
  #   extraConfig = ''
  #     include "/etc/bind/rndc.key";
  #     ddns-updates on;
  #     zone lan.xhain.space. {
  #       primary 127.0.0.1;
  #       key "rndc-key";
  #     }
  #     zone hosting.xhain.space. {
  #       primary 127.0.0.1;
  #       key "rndc-key";
  #     }
  #     zone guest.xhain.space. {
  #       primary 127.0.0.1;
  #       key "rndc-key";
  #     }
  #     subnet 192.168.42.0 netmask 255.255.254.0 {
  #       range 192.168.42.30 192.168.43.254;
  #       option routers 192.168.42.1;
  #       option domain-name-servers 192.168.42.1;
  #       option domain-search "lan.xhain.space.";
  #       option domain-name "lan.xhain.space.";
  #       ddns-domainname "lan.xhain.space.";
  #       interface intern;
  #     }
  #     subnet 45.158.40.192 netmask 255.255.255.192 {
  #       range 45.158.40.201 45.158.40.254;
  #       option routers 45.158.40.193;
  #       option domain-name-servers 45.158.40.193;
  #       option domain-search "hosting.xhain.space.";
  #       option domain-name "hosting.xhain.space.";
  #       ddns-domainname "hosting.xhain.space.";
  #       interface hosting;
  #     }
  #     subnet 192.168.12.0 netmask 255.255.254.0 {
  #       range 192.168.12.20 192.168.13.254;
  #       option routers 192.168.12.1;
  #       option domain-name-servers 192.168.12.1;
  #       option domain-search "guest.xhain.space.";
  #       option domain-name "guest.xhain.space.";
  #       ddns-domainname "guest.xhain.space.";
  #       interface guest;
  #     }
  #     subnet 10.73.243.0 netmask 255.255.255.0 {
  #       range 10.73.243.20 10.73.243.254;
  #       option routers 10.73.243.1;
  #       option domain-name-servers 10.73.243.1;
  #       option domain-search "lan.c3voc.de.";
  #       option domain-name "lan.c3voc.de.";
  #       ddns-domainname "lan.c3voc.de.";
  #       interface voc;
  #     }
  #     host nas {
  #       hardware ethernet 6c:bf:b5:00:61:fc;
  #       fixed-address 192.168.42.2;
  #       ddns-hostname "nas";
  #     }
  #   '';
  # };


}
