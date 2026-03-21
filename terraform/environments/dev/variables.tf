variable "node_name" {
  type = string
  #default = "vmi2685714"
  default = "pve"
}

variable "gateway" {
  type = string
  default = "192.168.2.1"
}

variable "pm_api_url" {
  type = string
  default = "https://192.168.2.100:8006"
}

variable "pm_host" { type = string }
variable "pm_user" { type = string }
variable "pm_password" {
  type      = string
  sensitive = true
}

variable "lxc_user" {
  type = string
}

variable "lxc_password" {
  type      = string
  sensitive = true
}

variable "lxc_ssh_key" {
  type      = string
  sensitive = true
  default   = ""
}