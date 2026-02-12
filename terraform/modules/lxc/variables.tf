variable "name" {
  type = string
}

variable "node" {
  type = string
}

variable "template" {
  type = string
  default = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
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