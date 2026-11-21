{ runCommand, fetchurl }:

let
  version = "0.1.0-beta.1";
  binary = fetchurl {
    url = "https://github.com/prusa3d/prusa-connect/releases/download/v${version}/prusa_connect_amd64";
    sha256 = "a3a1f69611bc59ec5dad494abd0fd04db7952fd7ac6f519ce0978217e8cf63a5";
  };
in
runCommand "prusa-connect-${version}" { } ''
  install -Dm755 ${binary} "$out/bin/prusa-connect"
''