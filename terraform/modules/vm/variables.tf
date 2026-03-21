variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    ip = string
    id = number
  }))
}

variable "node_name" {
  type = string
}

variable "vmid" { type = number }

#variable "name" { type = string }

variable "template_id" {
  type        = number
  description = "VM template ID (cloud-init template)"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "storage" {
  type    = string
  #default = "local"
  default = "local-lvm"
}

variable "disk_size" {
  type = number
  default = 20
}

#variable "ip" { type = string }
variable "gateway" { type = string }

variable "started" {
  type    = bool
  default = true
}

variable "vm_user" { type = string }
variable "vm_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "vm_ssh_keys" {
  type        = list(string)
  description = "SSH public keys"
  default     = []
}