# ==================================================== #
# Proxmox: Terraform - Providers File
# ==================================================== #

terraform {
  required_version = "~> 1.17.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.119.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
  #backend "azurerm" {} # Leave empty, to be inserted during for workflow.
}

# Configuration for Proxmox provider, using variables for flexibility and security.
provider "proxmox" {
  endpoint  = var.pve_api_url # API endpoint for Proxmox cluster, using first host in cluster.
  api_token = "${var.pve_api_user}=${var.pve_api_token}" # Pass in variable to avoid hard-coding.
  # Disable TLS certificate verification is required when using self-signed certificate.
  insecure  = true
}
