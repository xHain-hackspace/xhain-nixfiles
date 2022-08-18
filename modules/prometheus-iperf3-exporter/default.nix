{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.iperf3-exporter;
in {
  options = {
    services.iperf3-exporter = {
      enable = mkEnableOption "Enable iperf3 prometheus exporter";
      listenAddress = mkOption {
        type = types.str;
        default = "[::1]:9579";
      };
      iperf3OmitTime = mkOption { type = types.str; default = "5s"; };
      iperf3Mss = mkOption { type = types.int; default = 1400; };
      iperf3Path = mkOption { type = types.str; default = "${pkgs.iperf3}/bin/iperf3"; };
      iperf3Time = mkOption { type = types.str; default = "10s"; };
      iperf3Timeout = mkOption { type = types.str; default = "30s"; };
    };
  };
  config = mkIf cfg.enable {
    services.iperf3-exporter = {};

    systemd.services.iperf3-exporter = {
      description = "iperf3 prometheus exporter";
      documentation = [ "https://github.com/fluepke/iperf3-exporter" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iperf3 ];
      serviceConfig = {
        Restart = mkDefault "always";
        DynamicUser = "yes";
        ProtectSystem = "full";
        PrivateTmp = "true";
      };
      script = ''
        ${pkgs.prometheus-iperf3-exporter}/bin/iperf3-exporter \
          --iper3.omitTime=${cfg.iperf3OmitTime} \
          --iperf3.mss=${toString cfg.iperf3Mss} \
          --iperf3.path=${cfg.iperf3Path} \
          --iperf3.time=${cfg.iperf3Time} \
          --iperf3.timeout=${cfg.iperf3Timeout}
      '';
    };

    services.nginx.virtualHosts.${config.networking.fqdn} = {
      locations."/iperf3-exporter/metrics".proxyPass = "http://${cfg.listenAddress}/metrics";
      locations."/iperf3-exporter/probe".proxyPass = "http://${cfg.listenAddress}/probe";
    };
  };
}
