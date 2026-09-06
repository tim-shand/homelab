# ==================================================== #
# Proxmox: Terraform - Providers File
# ==================================================== #

terraform {
  required_version = "~> 1.16.0"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
  backend "azurerm" {} # Leave empty, to be inserted during for workflow.
}

# Configuration for Proxmox provider, using variables for flexibility and security.
provider "proxmox" {
  endpoint    = "https://${var.pve_nodes["node1"].ip_address}:8006/api2/json" # API endpoint for Proxmox cluster, using first host in cluster.
  api_token   = var.pve_auth_api_token # Pass in variable to avoid hard-coding.
  insecure    = true # Disable TLS certificate verification is required when using self-signed certificate.
}
