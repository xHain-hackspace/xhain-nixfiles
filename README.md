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

### Prusa Connect

The Proxmox container runs Prusa Connect at `https://pc.xhain.space`. Its Caddy
proxy uses a certificate obtained by Lego using RFC2136 DNS updates. Before
deploying the router configuration, provision a dedicated TSIG key on both
machines; otherwise BIND will fail to start because its key file is missing.

1. Generate a BIND key with `tsig-keygen -a hmac-sha256 acme-prusa-connect.lan.xhain.space`.
	Keep the output private and transfer the same file securely to both machines.
2. On the router, install it as `/var/lib/bind/acme-prusa-connect.key`, owned by
	`root:named` with mode `0640`. On the container, install it as
	`/var/lib/prusa-connect-acme/tsig.key`, owned by `root:root` with mode `0400`.
3. Deploy the router, then the container using `colmena apply --on router` and
	`colmena apply --on prusa-connect`. The DHCP-assigned container hostname must
	resolve as `prusa-connect.lan.xhain.space`.
4. Read the one-time setup code with `journalctl -u prusa-connect` on the
	container and complete the setup wizard. Keep the application listener
	unencrypted: Caddy terminates browser TLS.

The certificate's DNS challenge follows the CNAME at
`_acme-challenge.pc.xhain.space` to the host-specific record in the dynamic LAN
zone. Back up `/var/lib/prusa-connect`, which contains the database, settings,
and uploaded files. Updates are managed by Nix, not the application's updater.

Prusa printer firmware has stricter TLS requirements than browsers, including a
1024-byte certificate-chain limit. The public ACME certificate served by Caddy
may not work for printers; a compatible printer-facing TLS listener and trust
certificate must be set up separately before connecting printers. See the
[upstream certificate documentation](https://github.com/prusa3d/prusa-connect/blob/v0.1.0-beta.1/docs/src/content/docs/certificates.md).

### Formatting
This repo uses treefmt via [treefmt-nix](https://github.com/numtide/treefmt-nix).

Run `nix fmt` to format the codebase.

It's configured in `flake.nix`. A flake check is also avaiable to catch missed formatting in CI. 

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
