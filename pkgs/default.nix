{ pkgs, ... }:

let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom );
  custom = {
    prometheus-iperf3-exporter = callPackage ./prometheus-iperf3-exporter {};
  };
in custom
