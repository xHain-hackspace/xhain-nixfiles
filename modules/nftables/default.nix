{ pkgs, lib, config, modulesPath, ... }:

let
  fwcfg = config.networking.firewall;
  cfg = config.nftables;

  doDocker = config.virtualisation.docker.enable && cfg.generateDockerRules;

  mkPorts = cond: ports: ranges: action: let
    portStrings = (map (range: "${toString range.from}-${toString range.to}") ranges)
               ++ (map toString ports);
  in lib.optionalString (portStrings != []) ''
    ${cond} dport { ${lib.concatStringsSep ", " portStrings} } ${action}
  '';

  ruleset = ''
    table inet filter {
      chain input {
        type filter hook input priority filter
        policy ${cfg.inputPolicy}

        icmpv6 type { echo-request, echo-reply, mld-listener-query, mld-listener-report, mld-listener-done, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, packet-too-big } accept
        icmp type echo-request accept

        ct state invalid drop
        ct state established,related accept

        iifname { ${
          lib.concatStringsSep "," (["lo"] ++ fwcfg.trustedInterfaces)
        } } accept

        ${mkPorts "tcp" fwcfg.allowedTCPPorts fwcfg.allowedTCPPortRanges "accept"}
        ${mkPorts "udp" fwcfg.allowedUDPPorts fwcfg.allowedUDPPortRanges "accept"}

        ${
          lib.concatStringsSep "\n" (lib.mapAttrsToList (name: ifcfg:
              mkPorts "iifname ${name} tcp" ifcfg.allowedTCPPorts ifcfg.allowedTCPPortRanges "accept"
            + mkPorts "iifname ${name} udp" ifcfg.allowedUDPPorts ifcfg.allowedUDPPortRanges "accept"
          ) fwcfg.interfaces)
        }

        # DHCPv6
        ip6 daddr fe80::/64 udp dport 546 accept

        ${cfg.extraInput}

        counter
      }
      chain output {
        type filter hook output priority filter
        policy ${cfg.outputPolicy}

        ${cfg.extraOutput}

        counter
      }
      chain forward {
        type filter hook forward priority filter
        policy ${cfg.forwardPolicy}

        ${lib.optionalString doDocker ''
          oifname docker0 ct state invalid drop
          oifname docker0 ct state established,related accept
          iifname docker0 accept
        ''}

        ${cfg.extraForward}

        counter
      }
    }
    ${lib.optionalString doDocker ''
      table ip nat {
        chain docker-postrouting {
          type nat hook postrouting priority 10
          iifname docker0 masquerade
        }
      }
    ''}
    ${cfg.extraConfig}
  '';

  rulesetFile = pkgs.writeTextFile {
    name = "nftables-rules";
    text = ruleset;
  };

in {
  options = with lib; {
    nftables = {
      enable = mkEnableOption "nftables firewall";

      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      extraInput = mkOption {
        type = types.lines;
        default = "";
      };
      extraOutput = mkOption {
        type = types.lines;
        default = "";
      };
      extraForward = mkOption {
        type = types.lines;
        default = "";
      };
      inputPolicy = mkOption {
        type = types.str;
        default = "drop";
      };
      outputPolicy = mkOption {
        type = types.str;
        default = "accept";
      };
      forwardPolicy = mkOption {
        type = types.str;
        default = "accept";
      };
      generateDockerRules = mkOption {
        type = types.bool;
        default = true;
      };
      needIptables = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = false;

    environment.systemPackages = [ pkgs.nftables ];
    systemd.services.nftables = {
      description = "nftables firewall";
      before = [ "network-pre.target" ];
      wants = [ "network-pre.target" ];
      wantedBy = [ "multi-user.target" ];
      reloadIfChanged = true;
      serviceConfig = let
        rulesScript = pkgs.writeScript "nftables-rules" ''
          #! ${pkgs.nftables}/bin/nft -f
          flush ruleset
          include "${rulesetFile}"
        '';
        checkScript = pkgs.writeScript "nftables-check" ''
          #! ${pkgs.runtimeShell} -e
          if $(${pkgs.kmod}/bin/lsmod | grep -q ip_tables); then
            ${pkgs.iptables}/bin/iptables -P INPUT ACCEPT
            ${pkgs.iptables}/bin/iptables -P FORWARD ACCEPT
            ${pkgs.iptables}/bin/iptables -P OUTPUT ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -F
            ${pkgs.iptables}/bin/iptables -t mangle -F
            ${pkgs.iptables}/bin/iptables -F
            ${pkgs.iptables}/bin/iptables -X
          fi
          if $(${pkgs.kmod}/bin/lsmod | grep -q ip6_tables); then
            ${pkgs.iptables}/bin/ip6tables -P INPUT ACCEPT
            ${pkgs.iptables}/bin/ip6tables -P FORWARD ACCEPT
            ${pkgs.iptables}/bin/ip6tables -P OUTPUT ACCEPT
            ${pkgs.iptables}/bin/ip6tables -t nat -F
            ${pkgs.iptables}/bin/ip6tables -t mangle -F
            ${pkgs.iptables}/bin/ip6tables -F
            ${pkgs.iptables}/bin/ip6tables -X
          fi
          ${if cfg.needIptables then ''
            ${pkgs.kmod}/bin/modprobe iptable_filter iptable_mangle iptable_nat iptable_raw iptable_security ip_tables
            ${pkgs.kmod}/bin/modprobe ip6table_filter ip6table_mangle ip6table_nat ip6table_raw ip6table_security ip6_tables
          '' else ''
            ${pkgs.kmod}/bin/rmmod iptable_filter iptable_mangle iptable_nat iptable_raw iptable_security ip_tables || true
            ${pkgs.kmod}/bin/rmmod ip6table_filter ip6table_mangle ip6table_nat ip6table_raw ip6table_security ip6_tables || true
          ''}
          ${rulesScript}
        '';
      in {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = checkScript;
        ExecReload = checkScript;
        ExecStop = "${pkgs.nftables}/bin/nft flush ruleset";
      };
    };

    virtualisation.docker = lib.mkIf doDocker {
      extraOptions = "--iptables=false";
    };
  };
}
