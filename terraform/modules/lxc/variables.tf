variable "node_name" { type = string }
variable "vmid" { type = number }
variable "hostname" { type = string }

variable "template" {
  type = string
  default = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "swap" {
  type    = number
  default = 0
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

variable "ip" {
  type = string
}

variable "gateway" {
  type = string
  default = "192.168.2.1"
}

variable "started" {
  type    = bool
  default = true
}

variable "pm_host" { type = string }
variable "pm_user" { type = string }
variable "pm_password" {
  type      = string
  sensitive = true
}

variable "lxc_user" { type = string }
variable "lxc_password" {
  type      = string
  sensitive = true
}

variable "lxc_ssh_key" {
  type    = string
  default = ""
}