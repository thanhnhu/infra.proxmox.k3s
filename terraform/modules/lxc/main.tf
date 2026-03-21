resource "proxmox_virtual_environment_container" "lxc" {
  node_name = var.node_name
  vm_id     = var.vmid
  started   = true

  unprivileged = false

  features {
    nesting = true
    fuse    = true
    keyctl  = true
  }

  operating_system {
    template_file_id = var.template
    type             = "debian"
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.storage
    size         = var.disk_size
  }

  network_interface {
    name = "eth0"
    #bridge = "vmbr1" # VPS Network
    bridge = "vmbr0"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
    ]
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = "${var.ip}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }
  }
}

resource "null_resource" "create_user" {
  depends_on = [proxmox_virtual_environment_container.lxc]

  # Github Runner on Proxmox LXC
  connection {
    type     = "ssh"
    host     = var.pm_host
    user     = split("@", var.pm_user)[0] # if API User = 'root@pam'
    password = var.pm_password
    #private_key = file("~/.ssh/id_rsa")
    agent    = false
    insecure = true
    timeout  = "2m"
  }

  # Force re-run the provisioner "remote-exec" once update command
  triggers = {
    #script_hash = md5("apt-get update && apt-get install -y sudo")
    always = timestamp() # always run the provisioner "remote-exec"
  }

  # Github Runner on Proxmox Host
  #provisioner "local-exec" {
    #command = <<-EOT
      #sudo -n /usr/sbin/pct exec ${var.vmid} -- bash -c "\
        #apt-get update && apt-get install -y sudo; \
        #id -u ${var.lxc_user} &>/dev/null || adduser --disabled-password --gecos '' ${var.lxc_user}; \
        #echo '${var.lxc_user}:${var.lxc_password}' | chpasswd; \
        #usermod -aG sudo ${var.lxc_user}; \
        #mkdir -p /home/${var.lxc_user}/.ssh; \
        #chown -R ${var.lxc_user}:${var.lxc_user} /home/${var.lxc_user}/.ssh; \
      #"
    #EOT
  #}

  # Github Runner on Proxmox LXC
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        /usr/sbin/pct exec ${var.vmid} -- bash -c "
          set -e
          export DEBIAN_FRONTEND=noninteractive
          apt-get update && apt-get install -y sudo

          if ! id -u ${var.lxc_user} >/dev/null 2>&1; then
            adduser --disabled-password --gecos '' ${var.lxc_user}
          fi

          echo '${var.lxc_user}:${var.lxc_password}' | chpasswd
          usermod -aG sudo ${var.lxc_user}
          mkdir -p /home/${var.lxc_user}/.ssh
          chown -R ${var.lxc_user}:${var.lxc_user} /home/${var.lxc_user}/.ssh
        "
      EOT
    ]
  }
}

resource "null_resource" "fix_apparmor" {
  depends_on = [null_resource.create_user]

  # Github Runner on Proxmox LXC
  connection {
    type     = "ssh"
    host     = var.pm_host
    user     = split("@", var.pm_user)[0] # if API User = 'root@pam'
    password = var.pm_password
    #private_key = file("~/.ssh/id_rsa")
    agent    = false
    insecure = true
    timeout  = "2m"
  }

  triggers = {
    vmid = var.vmid
  }

  # Github Runner on Proxmox Host
  #provisioner "local-exec" {
    #command = <<-EOT
      #sudo sed -i '/lxc.apparmor.profile/d' /etc/pve/lxc/${var.vmid}.conf
      #sudo sed -i '/lxc.cap.drop/d' /etc/pve/lxc/${var.vmid}.conf
      #sudo bash -c "echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid}.conf"
      #sudo bash -c "echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid}.conf"
      #sudo pct stop ${var.vmid} && sudo pct start ${var.vmid}
    #EOT
  #}

  # Github Runner on Proxmox LXC
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        sed -i '/lxc.apparmor.profile/d' /etc/pve/lxc/${var.vmid}.conf
        sed -i '/lxc.cap.drop/d' /etc/pve/lxc/${var.vmid}.conf
        echo 'lxc.apparmor.profile: unconfined' >> /etc/pve/lxc/${var.vmid}.conf
        echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid}.conf
        pct stop ${var.vmid} && sleep 2
        pct start ${var.vmid}
      EOT
    ]
  }
}