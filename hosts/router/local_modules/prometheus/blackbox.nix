{ config, ... }:

{
  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    configFile = "${ ./blackbox-exporter.yml }";
  };

  services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} = let
    addr = config.services.prometheus.exporters.blackbox.listenAddress;
    port = toString config.services.prometheus.exporters.blackbox.port;
  in {
    locations."/blackbox-exporter/metrics".proxyPass = "http://${addr}:${port}/metrics";
    locations."/blackbox-exporter/probe".proxyPass = "http://${addr}:${port}/probe";
  };
}
