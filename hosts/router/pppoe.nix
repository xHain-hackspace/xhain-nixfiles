{ config , ... }:

{
  # todo: find a way to load pppoe kernel module
  
  secrets.pppoe_pap_secrets.owner = "systemd-network"; # todo: find the right owner

  environment.etc = {
    "ppp/pap-secrets" = { 
        source = config.secrets.pppoe_pap_secrets.path;
        mode = "0400";
      };
  };

  services.pppd = {
    enable = true;
    peers = {
      dsl = {
        autostart = true;
        enable = true;
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