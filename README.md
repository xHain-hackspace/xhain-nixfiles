# xHain nixfiles

### How to deploy the router:

```
nix build -f . deploy.router
./result switch
```

### Install updates

```
niv update
nix build -f . deploy.router
./result switch
```

### ToDo
* give routing tables names that can be read by humans
* schedule DSL reconnect
