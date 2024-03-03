{ config, ... }:

{
  services.prometheus.exporters.wireguard = {
    enable = true;
    listenAddress = "127.0.0.1";
  };

  services.nginx.virtualHosts.${config.networking.hostName + "." + config.networking.domain} = let
    addr = config.services.prometheus.exporters.wireguard.listenAddress;
    port = toString config.services.prometheus.exporters.wireguard.port;
  in {
    locations."/wireguard-exporter/metrics".proxyPass = "http://${addr}:${port}/metrics";
  };
}
