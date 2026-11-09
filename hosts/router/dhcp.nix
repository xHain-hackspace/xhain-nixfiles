{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  subnets = {
    lan = {
      id = 1;
      subnet = "192.168.42.0/23";
      router = "192.168.42.1";
      dhcp_range = "192.168.42.30 - 192.168.43.254";
      ipv6_subnet = "2a0f:5387:ffff:1342::/64";
      ipv6_router = "2a0f:5387:ffff:1342::1";
      ipv6_pool = "2a0f:5387:ffff:1342::1000 - 2a0f:5387:ffff:1342::ffff";
      ddns_domain = "lan.xhain.space.";
      reservations = [
        {
          hw-address = "3c:84:27:fd:f8:b0";
          hostname = "bambulab-a1";
        }
      ];
    };
    hosting = {
      id = 2;
      subnet = "45.158.40.192/26";
      router = "45.158.40.193";
      dhcp_range = "45.158.40.201 - 45.158.40.254";
      ipv6_subnet = "2a0f:5387:ffff:1337::/64";
      ipv6_router = "2a0f:5387:ffff:1337::1";
      ipv6_pool = "2a0f:5387:ffff:1337::1000 - 2a0f:5387:ffff:1337::ffff";
      ddns_domain = "hosting.xhain.space.";
    };
    guest = {
      id = 3;
      subnet = "192.168.12.0/23";
      router = "192.168.12.1";
      dhcp_range = "192.168.12.30 - 192.168.13.254";
      ipv6_subnet = "2a0f:5387:ffff:1312::/64";
      ipv6_router = "2a0f:5387:ffff:1312::1";
      ipv6_pool = "2a0f:5387:ffff:1312::1000 - 2a0f:5387:ffff:1312::ffff";
      ddns_domain = "guest.xhain.space.";
    };
    voc = {
      id = 4;
      subnet = "10.73.243.0/24";
      router = "10.73.243.1";
      dhcp_range = "10.73.243.20 - 10.73.243.254";
      ipv6_subnet = "2a0f:5387:ffff:1323::/64";
      ipv6_router = "2a0f:5387:ffff:1323::1";
      ipv6_pool = "2a0f:5387:ffff:1323::1000 - 2a0f:5387:ffff:1323::ffff";
      ddns_domain = "lan.c3voc.de.";
    };
  };

  mkKeaSubnet = name: attrs: {
    id = attrs.id;
    subnet = attrs.subnet;
    pools = [ { pool = attrs.dhcp_range; } ];
    reservations = attrs.reservations or [ ];
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
  mkKeaDdnsDomains = name: attrs: ''
    {
            "dns-servers": [{"ip-address": "127.0.0.1"}],
            "key-name": "rndc-key",
            "name": "${attrs.ddns_domain}"
          }'';
  mkKeaSubnet6 = name: attrs: {
    id = attrs.id;
    subnet = attrs.ipv6_subnet;
    pools = [ { pool = attrs.ipv6_pool; } ];
    ddns-qualifying-suffix = attrs.ddns_domain;
    option-data = [
      {
        name = "dns-servers";
        data = attrs.ipv6_router;
      }
      {
        name = "domain-search";
        data = attrs.ddns_domain;
      }
    ];
  };
  controlSocket = "/run/kea/dhcp4.sock";
in
{
  users.users.kea = {
    isSystemUser = true;
    group = "kea";
  };
  users.groups.kea = { };

  sops.secrets.kea-ddns-key = {
    owner = "kea";
  };

  services.kea = {
    dhcp4 = {
      enable = true;

      settings = {
        valid-lifetime = 7200;
        renew-timer = 3600;
        rebind-timer = 9800;

        interfaces-config = {
          interfaces = [
            "voc"
            "intern"
            "hosting"
            "guest"
          ];
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
        # DHCPv4 client IDs and DHCPv6 DUIDs differ even on one dual-stack
        # host. Avoid DHCID conflicts so A and AAAA can share its FQDN.
        ddns-conflict-resolution-mode = "no-check-with-dhcid";

        hostname-char-set = "[^A-Za-z0-9.-]";
        hostname-char-replacement = "-";

        subnet4 = lib.mapAttrsToList mkKeaSubnet subnets;

        client-classes = [
          {
            name = "uefi PXE Clients";
            test = "substring(option[60].hex,0,9) == 'PXEClient' and option[93].hex == 0x0007";
            next-server = "192.168.42.2";
            boot-file-name = "/uefi/BOOT/BOOTX64.EFI";
          }
          {
            name = "bios PXE Clients";
            test = "substring(option[60].hex,0,9) == 'PXEClient' and option[93].hex == 0x0000";
            next-server = "192.168.42.2";
            boot-file-name = "syslinux/pxelinux.0";
          }
          {
            name = "uefi HTTP Clients";
            #test = "substring(option[60].hex,0,10) == 'HTTPClient' and (option[93].hex == 0x0007 or option[93].hex == 0x0010)";
            test = "substring(option[60].hex,0,10) == 'HTTPClient'";
            option-data = [
              {
                space = "dhcp4";
                name = "vendor-class-identifier";
                code = 60;
                data = "HTTPClient";
              }
            ];
            boot-file-name = "https://boot.netboot.xyz/menu.ipxe";
          }
        ];

        control-sockets = [
          {
            socket-type = "unix";
            socket-name = controlSocket;
          }
        ];

        hooks-libraries = [
          {
            library = "${pkgs.kea}/lib/kea/hooks/libdhcp_lease_cmds.so";
            parameters = { };
          }
        ];

        # loggers = [
        #   {
        #     name = "kea-dhcp4";
        #     output_options = [
        #       {
        #         output = "stdout";
        #       }
        #     ];
        #     severity = "DEBUG";
        #     debuglevel = 0;
        #   }
        # ];
      };
    };

    dhcp6 = {
      enable = true;

      settings = {
        valid-lifetime = 7200;
        preferred-lifetime = 3600;
        renew-timer = 1800;
        rebind-timer = 3150;

        interfaces-config.interfaces = [
          "voc"
          "intern"
          "hosting"
          "guest"
        ];

        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp6.leases";
        };

        dhcp-ddns.enable-updates = true;
        ddns-override-client-update = true;
        ddns-override-no-update = true;
        ddns-update-on-renew = true;
        ddns-replace-client-name = "when-not-present";
        ddns-generated-prefix = "host6";
        ddns-conflict-resolution-mode = "no-check-with-dhcid";

        hostname-char-set = "[^A-Za-z0-9.-]";
        hostname-char-replacement = "-";

        subnet6 = lib.mapAttrsToList mkKeaSubnet6 subnets;
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
              <?include "${config.sops.secrets.kea-ddns-key.path}"?>
            ]
            # "loggers": [
            #   {
            #     "name": "kea-dhcp-ddns",
            #     "output_options": [
            #         {
            #             "output": "stdout",
            #             "pattern": "%-5p %m\n"
            #         }
            #     ],
            #     "severity": "DEBUG",
            #     "debuglevel": 0
            #   }
            # ]
          }
        }
      '';
    };
  };

  systemd.services.kea-dhcp4-server = {
    after = [ "bind.service" ];
    serviceConfig.DynamicUser = lib.mkForce false;
    preStart = ''
      if [ -e "${controlSocket}" ]; then
        echo "Removing stale control socket: ${controlSocket}"
        unlink "${controlSocket}" || echo "Failed to remove: ${controlSocket}"
      fi
    '';
  };
  systemd.services.kea-dhcp6-server = {
    after = [ "bind.service" ];
    serviceConfig.DynamicUser = lib.mkForce false;
  };
  systemd.services.kea-dhcp-ddns-server.serviceConfig.DynamicUser = lib.mkForce false;

  networking.firewall.interfaces =
    lib.genAttrs
      [
        "voc"
        "intern"
        "hosting"
        "guest"
      ]
      (_: {
        allowedUDPPorts = [ 547 ];
      });

  services.kea-lease-viewer = {
    enable = true;
    user = "kea";
    group = "kea";
    keaSocketPath = controlSocket;
  };

  services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} = {
    locations."/leases" = {
      recommendedProxySettings = true;
      proxyPass = "http://${config.services.kea-lease-viewer.listenAddress}:${toString config.services.kea-lease-viewer.port}/";
      extraConfig = ''
        proxy_set_header X-Admin-Request "true";
      '';
    };
    # the viewer's delete links are absolute (/delete?ip=...)
    locations."= /delete" = {
      recommendedProxySettings = true;
      proxyPass = "http://${config.services.kea-lease-viewer.listenAddress}:${toString config.services.kea-lease-viewer.port}";
      extraConfig = ''
        proxy_set_header X-Admin-Request "true";
      '';
    };
  };
}
