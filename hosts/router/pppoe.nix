{ config , ... }:

{
  environment.etc = {
    "ppp/pap-secrets".text = "test";
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