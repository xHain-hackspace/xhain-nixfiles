{ config, pkgs, lib, inputs, ... }:

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
        "key-name": "rndc-key",
        "name": "${attrs.ddns_domain}"
      }'';
  controlSocket = "/run/kea/dhcp4.sock";
in
{
  imports = [
    inputs.kea-lease-viewer.nixosModules.default
  ];

  users.users.kea = {
    isSystemUser = true;
    group = "kea";
  };
  users.groups.kea = { };

  secrets.kea-ddns-key.owner = "kea";

  services.kea = {
    dhcp4 = {
      enable = true;

      settings = {
        valid-lifetime = 7200;
        renew-timer = 3600;
        rebind-timer = 9800;

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

        control-socket = {
          socket-type = "unix";
          socket-name = controlSocket;
        };

        hooks-libraries = [
          {
            library = "/var/run/current-system/sw/lib/kea/hooks/libdhcp_lease_cmds.so";
            parameters = {};
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
              <?include "${config.secrets.kea-ddns-key.path}"?>
            ],
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

  systemd.services.kea-socket-permissions = {
    wantedBy = ["multi-user.target"];
    after = ["kea-dhcp4-server.service"];
    wants = ["kea-dhcp4-server.service"];
    preStart = ''
      /bin/sh -c 'while [ ! -e ${controlSocket} ]; do echo " Waiting for ${controlSocket} "; sleep 1; done'
    '';
    script = ''
      chown -v kea-lease-viewer:kea ${controlSocket}
      chmod -v 660 ${controlSocket}
      ln -f -v ${controlSocket} /run/kea-dhcp4.sock
    '';
  };

  services.kea-lease-viewer = {
    enable = true;
    keaSocketPath = "/run/kea-dhcp4.sock";
  };

   services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} =  {
    locations."/leases" = {
      recommendedProxySettings = true;
      proxyPass = "http://${config.services.kea-lease-viewer.listenAddress}:${toString config.services.kea-lease-viewer.port}/";
    };
  };
}
