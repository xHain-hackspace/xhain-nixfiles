variable "token" {
  description = "Proxmox API access token"
}

provider "proxmox" {
  pm_api_url          = "https://pve.xhain.space:8006/api2/json"
  pm_api_token_id     = "terraform@pve!terraform"
  pm_api_token_secret = var.token
}

resource "proxmox_lxc" "tr33" {
  target_node  = "pve"
  hostname     = "tr33"
  ostemplate   = "local:vztmpl/nixos-base.tar.xz"
  unprivileged = true
  cores        = 8
  onboot       = true
  start        = true
  memory       = 1028
  cmode        = "console"

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV
  EOT

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = "dhcp"
    ip6      = "dhcp"
    firewall = true
  }

  features {
    nesting = true
  }
}

resource "proxmox_lxc" "r33d" {
  target_node  = "pve"
  hostname     = "r33d"
  ostemplate   = "local:vztmpl/nixos-base.tar.xz"
  unprivileged = true
  cores        = 8
  onboot       = true
  start        = true
  memory       = 1028
  cmode        = "console"

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV
  EOT

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = "dhcp"
    ip6      = "dhcp"
    firewall = true
  }

  features {
    nesting = true
  }
}

resource "proxmox_lxc" "nix-builder" {
  target_node  = "pve"
  hostname     = "nix-builder"
  ostemplate   = "local:vztmpl/nixos-base.tar.xz"
  unprivileged = true
  cores        = 8
  onboot       = true
  start        = true
  memory       = 2048
  cmode        = "console"
  ostype       = "nixos"

  rootfs {
    storage = "local-zfs"
    size    = "30G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = "dhcp"
    ip6      = "dhcp"
    firewall = true
  }

  features {
    nesting = true
  }
}

resource "proxmox_lxc" "files" {
  target_node  = "pve"
  hostname     = "files"
  ostemplate   = "local:vztmpl/nixos-base.tar.xz"
  unprivileged = true
  cores        = 4
  onboot       = true
  start        = true
  memory       = 2048
  cmode        = "console"
  ostype       = "nixos"

  rootfs {
    storage = "local-zfs"
    size    = "30G"
  }

  mountpoint {
    key     = "0"
    slot    = 0
    storage = "local-zfs"
    mp      = "/media/storage"
    size    = "1T"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    ip       = "192.168.42.2/23"
    ip6      = "dhcp"
    firewall = true
  }

  features {
    nesting = true
  }
}
