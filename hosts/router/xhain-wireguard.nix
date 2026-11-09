{ config, ... }:

let
  firewallMark = 51829;

  mkNetdev =
    {
      name,
      privateKeyFile,
      listenPort,
      peerPublicKey,
      presharedKeyFile,
      endpoint,
    }:
    {
      netdevConfig = {
        Name = name;
        Kind = "wireguard";
        MTUBytes = 1380;
      };
      wireguardConfig = {
        PrivateKeyFile = privateKeyFile;
        ListenPort = listenPort;
        FirewallMark = firewallMark;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = peerPublicKey;
            PresharedKeyFile = presharedKeyFile;
            Endpoint = endpoint;
            PersistentKeepalive = 25;
            AllowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
            RouteTable = "off";
          };
        }
      ];
    };

  mkNetwork = name: address: {
    matchConfig.Name = name;
    linkConfig.RequiredForOnline = false;
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
      LinkLocalAddressing = "no";
      ConfigureWithoutCarrier = true;
    };
    address = [ address ];
  };
in
{
  sops.secrets = {
    wireguard_node0_private.owner = "systemd-network";
    wireguard_node0_psk.owner = "systemd-network";
    wireguard_node1_private.owner = "systemd-network";
    wireguard_node1_psk.owner = "systemd-network";
    wireguard_node2_private.owner = "systemd-network";
    wireguard_node2_psk.owner = "systemd-network";
  };

  systemd.network = {
    netdevs = {
      "50-wg-node0" = mkNetdev {
        name = "wg-node0";
        privateKeyFile = config.sops.secrets.wireguard_node0_private.path;
        listenPort = 51830;
        peerPublicKey = "Z082gEHmJogIDfm6XWcoWs/GyxV9zeZfHPo3J+WyozE=";
        presharedKeyFile = config.sops.secrets.wireguard_node0_psk.path;
        endpoint = "217.197.83.150:51826";
      };
      "50-wg-node1" = mkNetdev {
        name = "wg-node1";
        privateKeyFile = config.sops.secrets.wireguard_node1_private.path;
        listenPort = 51831;
        peerPublicKey = "tdphASYfVh8kPqEL93fxYi2U23I4ZHm1dxmf3e+uMjw=";
        presharedKeyFile = config.sops.secrets.wireguard_node1_psk.path;
        endpoint = "62.176.254.49:51826";
      };
      "50-wg-node2" = mkNetdev {
        name = "wg-node2";
        privateKeyFile = config.sops.secrets.wireguard_node2_private.path;
        listenPort = 51832;
        peerPublicKey = "UdTYGSCFb/iYWva2qEyDiqWL/6VuoTrvAwI7CawXuFA=";
        presharedKeyFile = config.sops.secrets.wireguard_node2_psk.path;
        endpoint = "45.158.42.0:51826";
      };
    };

    networks = {
      "50-wg-node0" = (mkNetwork "wg-node0" "fe80::208:135:100/64") // {
        routingPolicyRules = [
          {
            routingPolicyRuleConfig = {
              FirewallMark = firewallMark;
              Table = "main";
              Priority = 1110;
              Family = "both";
            };
          }
          {
            routingPolicyRuleConfig = {
              FirewallMark = firewallMark;
              Type = "unreachable";
              Priority = 1210;
              Family = "both";
            };
          }
        ];
      };
      "50-wg-node1" = mkNetwork "wg-node1" "fe80::208:135:101/64";
      "50-wg-node2" = mkNetwork "wg-node2" "fe80::208:135:102/64";
    };
  };

  networking.firewall.allowedUDPPorts = [
    51830
    51831
    51832
  ];
}
