# xHain nixfiles

### How to deploy the router

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

### Rolling back

Use the `rollback` script on any machine provisioned by this repo to revert to a previous version.

### Secrets

Secrets live in `secrets/` and are managed with [sops-nix](https://github.com/mic92/sops-nix).

### ToDo

* give routing tables names that can be read by humans
* schedule DSL reconnect

## Using the builder

If your machine is not native x64 Linux you can use the hosted builder.

### Prerequisites

* your ssh-key needs to be deployed to the builder (see [nix-builder](hosts/nix-builder/configuration.nix))
* the ssh key must not be password protected so please create a new one

### How to configure

* edit `/etc/nix/nix.conf` or `~/.config/nix/nix.conf` to include

```ini
# /etc/nix/nix.conf
builders = @/etc/nix/machines
```

* edit `/etc/nix/machines` to include

```ini
ssh-ng://builder@nix-builder.lan.xhain.space x86_64-linux  <path_to_your_ssh_key> 8 2 big-parallel
```
