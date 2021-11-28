# xHain nixfiles

### How to deploy the router:

```
nixos-rebuild switch --target-host 2a0f:5382:acab:1300::1 --use-remote-sudo -I nixpkgs=channel:nixos-unstable -I nixos-config=hosts/xhain/configuration.nix
```
