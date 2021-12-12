{ config, pkgs, ... }:

{
  boot.kernelModules = [ "pppoe" ];
  
  secrets.pppoe_pap_secrets = {}; 

  networking.interfaces.enp2s0 = {  };

  environment.etc = {
    "ppp/pap-secrets" = { 
        source = config.secrets.pppoe_pap_secrets.path;
      };
    "ppp/ip-up" = {
      text = ''
        #!/bin/sh
        echo $@ > /tmp/asdf
        ${pkgs.iproute2}/bin/ip route add default dev $1 src $4 metric 420
      '';
      mode = "0755";
    };
    "ppp/ip-down" = {
      text = ''
        #!/bin/sh
        ${pkgs.iproute2}/bin/ip route del default dev $1 src $4 metric 420
      '';
      mode = "0755";
    };
  };

  services.pppd = {
    enable = true;
    peers = {
      dsl = {
        config = 
        ''        
          plugin rp-pppoe.so enp2s0

          name "H1und1/ui2887-291@online.de"

          lcp-echo-interval 1
          lcp-echo-failure 5
          debug
          persist
          maxfail 0
          holdoff 5

          nodefaultroute
          noipdefault
        '';
      };
    };
  };
}
