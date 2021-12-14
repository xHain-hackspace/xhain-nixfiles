{ config, ... }:

{
  imports = [
    ./node.nix
    ./wireguard.nix
    ./blackbox.nix
  ];

  services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} = let
    addr = config.services.prometheus.listenAddress;
    port = toString config.services.prometheus.port;
  in {
    locations."/prometheus/".proxyPass = "http://${addr}:${port}/";
  };

  secrets.homeassistant_token.owner = "prometheus";

  services.prometheus = {
    enable = true;
    extraFlags = [ "--web.external-url='https://router.xhain.space/prometheus/'" "--web.route-prefix='/'" ];
    listenAddress = "127.0.0.1";
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = let
      removePort = [{
        source_labels = [ "__address__" ];
        target_label = "instance";
        regex = "^(.*):?\\d*";
        action = "replace";
      }];
      rewriteToLocal = [
        {
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        }
        {
          source_labels = [ "__param_target" ];
          target_label = "instance";
        }
        {
          replacement = "${config.networking.hostName + "." + config.networking.domain}";
          target_label = "__address__";
        }
      ];
    in
    [
      {
        job_name = "node";
        scheme = "https";
        metrics_path = "node-exporter/metrics";
        relabel_configs = removePort;
        static_configs = [{ targets = [ "${config.networking.hostName + "." + config.networking.domain}"]; }];
      }
      {
        job_name = "wireguard";
        scheme = "https";
        metrics_path = "wireguard-exporter/metrics";
        relabel_configs = removePort;
        static_configs = [{ targets = [ "${config.networking.hostName + "." + config.networking.domain}"]; }];
      }
      {
        job_name = "snmp";
        scheme = "https";
        metrics_path = "snmp-exporter/metrics";
        relabel_configs = removePort;
        static_configs = [{ targets = [ "${config.networking.hostName + "." + config.networking.domain}"]; }];
      }
      {
        job_name = "prometheus";
        scheme = "https";
        metrics_path = "prometheus/metrics";
        relabel_configs = removePort;
        static_configs = [{ targets = [ "${config.networking.hostName + "." + config.networking.domain}"]; }];
      }
      {
        job_name = "blackbox";
        scheme = "https";
        metrics_path = "blackbox-exporter/metrics";
        relabel_configs = removePort;
        static_configs = [{ targets = [ "${config.networking.hostName + "." + config.networking.domain}"]; }];
      }
      {
        job_name = "aruba";
        scheme = "https";
        metrics_path = "/snmp-exporter/snmp";
        params = { module = [ "aruba" ]; };
        relabel_configs = rewriteToLocal;
        static_configs = [{ targets = [ "wifi.xhain.space"] ; }];
      }
      {
        job_name = "switches";
        scheme = "https";
        metrics_path = "/snmp-exporter/snmp";
        params = { module = [ "if_mib" ]; };
        relabel_configs = rewriteToLocal;
        static_configs = [{
          targets = [
            "sw-tuer.xhain.space"
            "sw-keller.xhain.space"
            "sw-3dlab.xhain.space"
            "sw-maschinenraum.xhain.space"
          ];
        }];
      }
      {
        job_name = "blackbox-icmp";
        scheme = "https";
        metrics_path = "/blackbox-exporter/probe";
        params = { module = [ "icmp" ]; };
        relabel_configs = rewriteToLocal;
        static_configs = [{
          targets = [
            "sw-tuer.xhain.space"
            "sw-keller.xhain.space"
            "sw-3dlab.xhain.space"
            "sw-maschinenraum.xhain.space"
            "xdoor.lan.xhain.space"
            "45.158.40.1"
            "x-hain.de"
          ];
        }];
      }
      {
        job_name = "homeassistant";
        scheme = "http";
        metrics_path = "/api/prometheus";
        bearer_token_file = config.secrets.homeassistant_token.path;
        static_configs = [{
          targets = [
            "automation.lan.xhain.space"
          ];
        }];
      }
    ];
  };
}
