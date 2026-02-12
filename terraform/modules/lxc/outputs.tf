output "vm_name" {
  value = proxmox_vm_qemu.vm.name
}

output "vm_ip" {
  value = var.ip
}