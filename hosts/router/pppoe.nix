{ config , ... }:

{
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
          login

          persist
          maxfail 0
          holdoff 5

          noipdefault
        '';
      };
    };
  };
}