terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  #pm_api_token_id = "terraform@pve!terraform-token"
  #pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}