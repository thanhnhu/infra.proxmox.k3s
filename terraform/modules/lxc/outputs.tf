output "container_id" {
  value = proxmox_virtual_environment_container.lxc.id
}

output "vm_id" {
  value = proxmox_virtual_environment_container.lxc.vm_id
}

output "vm_name" {
  value = var.hostname
}

output "vm_ip" {
  value = var.ip
}