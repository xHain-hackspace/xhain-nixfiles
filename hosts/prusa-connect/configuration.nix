{ pkgs, name, ... }:

let
  host = "prusa-connect.lan.xhain.space";
  prusa-connect = pkgs.callPackage ../../pkgs/prusa-connect { };
  configFile = pkgs.writeText "prusa-connect.yaml" ''
    core:
      api:
        addr: "127.0.0.1:8080"
      trusted_proxies:
        - 127.0.0.1
      upgrade:
        enabled: false
    resources:
      storage:
        local:
          type: filesystem
          enabled: true
          config:
            root: ./storage
  '';
in
{
  imports = [
    ../../modules/proxmox_server
    ../../modules/rollback
    ../../modules/groups/admins.nix
  ];

  sops.secrets."bind-acme-prusa-connect.lan.xhain.space" = {
    sopsFile = ../../secrets/prusa-connect.yaml;
    path = "/var/lib/prusa-connect-acme/tsig.key";
    owner = "acme";
    group = "acme";
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/prusa-connect-acme 0700 acme acme -"
  ];

  networking.hostName = name;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  users.groups.prusa-connect = { };
  users.users.prusa-connect = {
    isSystemUser = true;
    group = "prusa-connect";
    home = "/var/lib/prusa-connect";
  };

  systemd.services.prusa-connect = {
    description = "Prusa Connect";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "prusa-connect";
      Group = "prusa-connect";
      StateDirectory = "prusa-connect";
      StateDirectoryMode = "0700";
      WorkingDirectory = "/var/lib/prusa-connect";
      ExecStart = "${prusa-connect}/bin/prusa-connect -config /var/lib/prusa-connect/config/config.yaml -addr 127.0.0.1:8080";
      Restart = "on-failure";
      UMask = "0077";
    };
    preStart = ''
      mkdir -p /var/lib/prusa-connect/config
      ln -sfn ${configFile} /var/lib/prusa-connect/config/config.yaml
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@x-hain.de";
    certs.${host} = {
      dnsProvider = "rfc2136";
      dnsResolver = "192.168.42.1:53";
      credentialFiles.DNSUPDATE_TSIG_FILE = "/var/lib/prusa-connect-acme/tsig.key";
    };
  };

  systemd.services."acme-order-renew-${host}".environment.DNSUPDATE_NAMESERVER = "192.168.42.1:53";

  services.caddy = {
    enable = true;
    virtualHosts.${host} = {
      useACMEHost = host;
      extraConfig = ''
        reverse_proxy 127.0.0.1:8080 {
          flush_interval -1
        }
      '';
    };
  };
}
