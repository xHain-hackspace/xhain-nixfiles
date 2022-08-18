{ pkgs }:

with pkgs.lib;

rec {
  hostsDir = ../hosts;

  hostNames = attrNames (
    filterAttrs (
      name: type: type == "directory"
    ) (
      builtins.readDir hostsDir
    )
  );

  hosts = listToAttrs (
    map (
      hostName: nameValuePair hostName (
        import (pkgs.path + "/nixos") {
          configuration = { ... }: {
            _module.args = {
              inherit hosts groups;
            };
            imports = [
              (hostsDir + "/${hostName}/configuration.nix")
            ];
          };
        }
      )
    ) hostNames
  );

  groupNames = unique (
    concatLists (
      mapAttrsToList (
        name: host: host.config.fluepke.deploy.groups
      ) hosts
    )
  );

  groups = listToAttrs (
    map (
      groupName: nameValuePair groupName (
        filter (
          host: elem groupName host.config.fluepke.deploy.groups
        ) (
          attrValues hosts
        )
      )
    ) groupNames
  );

  sshConfig = let
    mkConfigSection = withDomain: name: host: ''
      Host ${if withDomain then "${host.config.networking.hostName}.${host.config.networking.domain}" else name}
         HostName ${host.config.fluepke.deploy.ssh.host}
         Port ${toString host.config.fluepke.deploy.ssh.port}
    '';
    getAddresses = type: host: concatLists (
      mapAttrsToList (
        name: iface: map (
          addr: addr.address
        ) (
          iface.${type}.addresses
        )
      ) (
        filterAttrs (
          name: iface: name != "lo"
        ) host.config.networking.interfaces
      )
    );
    getFirstAddress = type: host: head (
      getAddresses type host
    );
  in pkgs.writeText "ssh-config" (
    concatStringsSep "\n" (
      concatLists (
        mapAttrsToList (
          name: host: [
            (mkConfigSection false name host)
            (mkConfigSection true name host)
          ]
        ) hosts
      )
    )
#${getFirstAddress host}
  );
}

