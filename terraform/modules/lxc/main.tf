resource "proxmox_lxc" "lxc" {
  target_node  = var.node
  hostname     = var.hostname
  ostemplate   = var.template
  #ostemplate   = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"

  cores  = var.cores
  memory = var.memory

  rootfs {
    storage = var.storage
    size    = var.disk_size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${var.ip}/24"
    gw     = var.gateway
  }

  password      = var.password
  unprivileged  = false
  features {
    nesting = true
  }
}