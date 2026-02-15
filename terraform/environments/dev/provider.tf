terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}


provider "proxmox" {
  insecure  = true
  endpoint	= var.pm_api_url
  username	= var.pm_user
  password	= var.pm_password
  #pm_api_token_id = "terraform@pve!terraform-token"
  #pm_api_token_secret = var.pm_api_token_secret
}