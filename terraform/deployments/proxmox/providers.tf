# ==================================================== #
# Proxmox: Terraform - Providers File
# ==================================================== #

terraform {
  required_version = "~> 1.15.5"
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.109.0"
    }
  }
}

# Configuration for Proxmox provider, using variables for flexibility and security.
provider "proxmox" {
  endpoint    = "https://${var.pve_nodes["node1"].ip_address}:8006/api2/json" # API endpoint for Proxmox cluster, using first host in cluster.
  api_token   = var.pve_auth_api_token # Pass in variable to avoid hard-coding.
  insecure    = true # Disable TLS certificate verification is required when using self-signed certificate.
  # ssh {
  #   agent = true # Required for some actions not supported by Proxmox API, creating custom disks (templates).
  #   username  = var.pve_auth_ssh_un
  #   private_key = file(var.pve_auth_ssh_keyfile) # Generate local key-pair: ssh-keygen -t ed25519 | Add .pub to PVE node: ssh-copy-id user@pve_node
  # }
}
