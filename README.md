# xHain nixfiles

### How to deploy the router:

```
nixos-rebuild switch --target-host router.xhain.space --use-remote-sudo -I nixpkgs=channel:nixos-unstable -I nixos-config=hosts/xhain/configuration.nix
```

### ToDo
* give routing tables names that can be read by humans
* schedule DSL reconnect
