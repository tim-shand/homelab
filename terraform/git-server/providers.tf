terraform {
  required_version = "~> 1.16.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://${var.pve_nodes["node1"].network.ip_address}:8006/api2/json" # API endpoint for Proxmox cluster, using first host in cluster.
  api_token = "${var.pve_api_terraform_user}=${var.pve_api_terraform_token}"
  insecure  = true # Disable TLS certificate verification is required when using self-signed certificate.
}
