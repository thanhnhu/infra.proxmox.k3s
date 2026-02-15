variable "node_name" {
  type = string
  default = "vmi2685714"
}

variable "gateway" {
  type = string
  default = "192.168.1.1"
}

variable "pm_api_url" {
  type = string
  default = "https://192.168.1.10:8006"
}

variable "pm_user" { type = string }
variable "pm_password" { type = string }