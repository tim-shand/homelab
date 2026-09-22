# ======================================================== #
# MODULE: Proxmox IAM - Service Account Users
# DESCRIPTION: Create service account users and assign to groups + add API token.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user
# ======================================================== #

terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
}

locals {
  formatted_date = formatdate("YYYY-MM-DD_HH-mm", timestamp())
}

# Proxmox: Service Account Users --------------------------------------------------- #
resource "proxmox_virtual_environment_user" "main" {
  user_id  = var.user_id
  comment  = "Managed by Terraform: ${var.user_comment}"
  groups   = var.user_groups
}

resource "proxmox_user_token" "user_token" {
  user_id         = proxmox_virtual_environment_user.main.user_id
  token_name      = "api" # Used to form the connection string (svc-account@pve!api=token_string).
  comment         = "Managed by Terraform: ${local.formatted_date}"
  privileges_separation = false
}
