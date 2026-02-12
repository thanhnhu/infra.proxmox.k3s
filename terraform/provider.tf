terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
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