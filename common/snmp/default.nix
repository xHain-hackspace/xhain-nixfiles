{ lib, config, pkgs, ...}:

{
  services.prometheus.exporters.snmp = {
    enable = true;
    listenAddress = "127.0.0.1";
    configurationPath = "${./snmp.yml}";
  };
  services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} = let
    addr = config.services.prometheus.exporters.snmp.listenAddress;
    port = toString config.services.prometheus.exporters.snmp.port;
  in {
    locations."/snmp-exporter/metrics".proxyPass = "http://${addr}:${port}/metrics";
    locations."/snmp-exporter/snmp".proxyPass = "http://${addr}:${port}/snmp";
  };
}
