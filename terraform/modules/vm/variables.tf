variable "node_name" {
  type = string
}

variable "vmid" { type = number }

variable "name" {
  type = string
}

variable "template" {
  type = string
  default = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
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
  default = "local"
}

variable "disk_size" { type = string }
variable "ip" { type = string }
variable "gateway" { type = string }
variable "password" { type = string }
