{ config, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
    enabledCollectors = [ "systemd" ];
  };

  services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} = let
    addr = config.services.prometheus.exporters.node.listenAddress;
    port = toString config.services.prometheus.exporters.node.port;
  in {
    locations."/node-exporter/metrics".proxyPass = "http://${addr}:${port}/metrics";
  };
}
