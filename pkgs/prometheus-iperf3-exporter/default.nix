{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-iperf3-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "fluepke";
    repo = "iperf3-exporter";
    sha256 = "0dxmq9dbmz9pkapr9d1yrcl3m650ik6vb6ggv253sf7gwav4i378";
    rev = "b77a187756dd36fd7bd607bbe5d5f19122cce464";
  };
  goPackagePath = "github.com/fluepke/iperf3-exporter";
  goDeps = ./deps.nix;

  meta = with lib; {
    description = "The iPerf3 exporter allows iPerf3 probing of endpoints";
    homepage = "https://github.com/fluepke/iperf3-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.linux;
  };
}
