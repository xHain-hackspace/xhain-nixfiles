# xHain nixfiles

### How to deploy the router:

```
colmena apply --on router
```

### Install updates

```
nix flake update
```

### VM Tests
There are some VM tests in `checks/` testing some critical services. You can run them like this:
```bash
nix build .#checks.x86_64-linux.<check-name>
```

Note: `nix flake check` cannot be used as currently the repo is unformatted (formatter check is inherited from flakelight)

### Secrets

* Manage secrets
```
  lib/pass.h
```

* Add new keys in `secrets/.public-keys`

### ToDo
* give routing tables names that can be read by humans
* schedule DSL reconnect
