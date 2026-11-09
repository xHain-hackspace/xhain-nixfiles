{...}: {
  services.bird = {
    enable = true;
    config = ''
      router id 45.158.40.192;

      define MY_ASN = 4200208135;
      define FLUEPKE_ASN = 208135;
      define XHAIN_PREFIX_V6 = 2a0f:5387:ffff::/48;

      ipv6 table xhain_full_v6;

      protocol device {
        scan time 10;
      }

      protocol bfd {
        interface "wg-node*" {
          min rx interval 300 ms;
          min tx interval 300 ms;
          idle tx interval 1 s;
          multiplier 3;
        };
      }

      protocol static originate_xhain_v6 {
        ipv6 {
          table xhain_full_v6;
        };

        route XHAIN_PREFIX_V6 blackhole;
      }

      protocol kernel kernel_full_v6 {
        kernel table 208135;
        scan time 10;

        ipv6 {
          table xhain_full_v6;
          import none;
          export all;
        };
      }

      filter import_node0_v6 {
        if net = XHAIN_PREFIX_V6 then reject;
        if net = ::/0 then reject;
        if net.len > 48 then reject;
        bgp_local_pref = 300;
        accept;
      }

      filter import_node2_v6 {
        if net = XHAIN_PREFIX_V6 then reject;
        if net = ::/0 then reject;
        if net.len > 48 then reject;
        bgp_local_pref = 200;
        accept;
      }

      filter import_node1_v6 {
        if net = XHAIN_PREFIX_V6 then reject;
        if net = ::/0 then reject;
        if net.len > 48 then reject;
        bgp_local_pref = 100;
        accept;
      }

      filter export_node0_v6 {
        if net = XHAIN_PREFIX_V6 && proto = "originate_xhain_v6" then accept;
        reject;
      }

      filter export_node2_v6 {
        if net = XHAIN_PREFIX_V6 && proto = "originate_xhain_v6" then {
          bgp_path.prepend(MY_ASN);
          accept;
        }
        reject;
      }

      filter export_node1_v6 {
        if net = XHAIN_PREFIX_V6 && proto = "originate_xhain_v6" then {
          bgp_path.prepend(MY_ASN);
          bgp_path.prepend(MY_ASN);
          accept;
        }
        reject;
      }

      template bgp fluepke_v6 {
        local as MY_ASN;
        neighbor as FLUEPKE_ASN;
        direct;
        bfd on;
        hold time 9;
        keepalive time 3;

        ipv6 {
          table xhain_full_v6;
          import keep filtered;
          import none;
          export none;
          next hop self;
        };
      }

      protocol bgp node0_v6 from fluepke_v6 {
        source address fe80::208:135:100;
        neighbor fe80::208:135:0%'wg-node0' as FLUEPKE_ASN;
        interface "wg-node0";

        ipv6 {
          table xhain_full_v6;
          import keep filtered;
          import filter import_node0_v6;
          export filter export_node0_v6;
          next hop self;
        };
      }

      protocol bgp node2_v6 from fluepke_v6 {
        source address fe80::208:135:102;
        neighbor fe80::208:135:2%'wg-node2' as FLUEPKE_ASN;
        interface "wg-node2";

        ipv6 {
          table xhain_full_v6;
          import keep filtered;
          import filter import_node2_v6;
          export filter export_node2_v6;
          next hop self;
        };
      }

      protocol bgp node1_v6 from fluepke_v6 {
        source address fe80::208:135:101;
        neighbor fe80::208:135:1%'wg-node1' as FLUEPKE_ASN;
        interface "wg-node1";

        ipv6 {
          table xhain_full_v6;
          import keep filtered;
          import filter import_node1_v6;
          export filter export_node1_v6;
          next hop self;
        };
      }
    '';
  };
}
