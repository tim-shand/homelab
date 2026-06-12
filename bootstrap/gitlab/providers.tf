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
  endpoint    = "https://${var.bootstrap_pve_node.ip_address}:8006/api2/json" # API endpoint for Proxmox cluster, using first host in cluster.
  username    = var.bootstrap_pve_un # Proxmox username for authentication. Prompted for password input during runtime.
  password    = var.bootstrap_pve_pw # Prompted for password input during runtime.
  insecure    = true # Disable TLS certificate verification is required when using self-signed certificate.
}
