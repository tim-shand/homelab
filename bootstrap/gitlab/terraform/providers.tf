terraform {
  required_version = "~> 1.15.5"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.109.0"
    }
  }
}

provider "proxmox" {
  endpoint    = "https://${var.pve_connection.ip_address}:8006/api2/json"
  api_token   = var.pve_connection.api_token
  insecure    = true # Disable TLS certificate verification is required when using self-signed certificate.
}
