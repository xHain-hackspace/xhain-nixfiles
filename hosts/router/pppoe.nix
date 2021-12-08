{ config , ... }:

{
  # todo: find a way to load pppoe kernel module
  
  secrets.pppoe_pap_secrets = {}; 

  environment.etc = {
    "ppp/pap-secrets" = { 
        source = config.secrets.pppoe_pap_secrets.path;
      };
  };

  services.pppd = {
    enable = true;
    peers = {
      dsl = {
        config = 
        ''        
          plugin rp-pppoe.so 

          #todo: network interface
          eth1

          name "H1und1/ui2887-291@online.de"

          persist
          maxfail 0
          holdoff 5

          defaultroute
          noipdefault
        '';
      };
    };
  };
}