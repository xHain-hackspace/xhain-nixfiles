# xHain nixfiles

### How to deploy the router:

```
colmena apply --on router
```

### Install updates

```
nix flake update
```

### Secrets

* Manage secrets
```
  lib/pass.h
```

* Add new keys in `secrets/.public-keys`

### ToDo
* give routing tables names that can be read by humans
* schedule DSL reconnect
