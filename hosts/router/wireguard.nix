{ config, ... }:

let
  port = 51820;
in {
  secrets.wireguard.owner = "systemd-network";

  systemd.network = {
    netdevs = {
      "40-wg0" = {
        netdevConfig = {
          Name = "wg0";
          Kind = "wireguard";
          MTUBytes = "1500";
        };
        wireguardConfig = {
          PrivateKeyFile = config.secrets.wireguard.path;
          ListenPort = port;
          FirewallMark = port;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "zrY+mrpozwcv4ZkqCDkVAwx9aISAX6JZOGzpZBsFonc=";
              PersistentKeepalive = 21;
              Endpoint = "45.158.40.1:51213";
              AllowedIPs = [ "0.0.0.0/0" "::/0" ];
            };
          }
        ];
      };
    };
    networks = {
      "40-wg0" = {
        name = "wg0";
        routingPolicyRules = [
          {
            routingPolicyRuleConfig = {
              Table = "main";
              SuppressPrefixLength = 0;
              Priority = 1000;
              Family = "both";
            };
          }
          {
            routingPolicyRuleConfig = {
              FirewallMark = port;
              Table = "main";
              Priority = 1100;
              Family = "both";
            };
          }
          {
            routingPolicyRuleConfig = {
              FirewallMark = port;
              Type = "unreachable";
              Priority = 1200;
              Family = "both";
            };
          }
          {
            routingPolicyRuleConfig = {
              From = "192.168.12.0/23";
              Table = 51820;
              Priority = 1300;
            };
          }
          {
            routingPolicyRuleConfig = {
              From = "192.168.42.0/23";
              Table = 51820;
              Priority = 1300;
            };
          }
          {
            routingPolicyRuleConfig = {
              From = "45.158.40.192/26";
              Table = 51820;
              Priority = 1400;
            };
          }
          {
            routingPolicyRuleConfig = {
              From = "2a0f:5382:acab:1300::/56";
              Table = 51820;
              Priority = 1400;
            };
          }
          {
            routingPolicyRuleConfig = {
              Table = "main";
              Priority = 1500;
              Family = "both";
            };
          }
        ];
        routes = [
          {
            routeConfig = {
              Scope = "link";
              Destination = "0.0.0.0/0";
              Table = port;
            };
          }
          {
            routeConfig = {
              Scope = "link";
              Destination = "::/0";
              Table = port;
            };
          }
        ];
      };
    };
  };

  networking.interfaces.wg0 = {
    ipv4.addresses = [
      { address = "45.158.40.192"; prefixLength = 32; }
    ];
    ipv6.addresses = [
      { address = "2a0f:5382:acab:1300::1"; prefixLength = 128; }
    ];
  };

  networking.firewall.checkReversePath = false;
  boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = false;
  boot.kernel.sysctl."net.ipv4.conf.*.rp_filter" = false;

  networking.firewall.allowedUDPPorts = [
    config.systemd.network.netdevs."40-wg0".wireguardConfig.ListenPort
  ];
}
