{ lib, ... }:

{
  services.iperf3-exporter = {
    enable = lib.mkDefault true;
    iperf3OmitTime = "10s";
  };
}
