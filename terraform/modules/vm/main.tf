resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  node_name = var.node_name
  vm_id     = var.vmid + each.value.id
  #name     = "${var.hostname}-${count.index}"
  name      = each.key
  started   = true

  clone {
    vm_id = var.template_id # Debian Cloud Image template Id: 9000
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    interface = "scsi0"
    size      = var.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        #address = "${var.ip}/24"
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }

    user_account {
      username = var.vm_user
      password = var.vm_password
      ##keys = [file("${path.module}/id_rsa.pub")]
      #keys = var.vm_ssh_keys
    }
  }
}