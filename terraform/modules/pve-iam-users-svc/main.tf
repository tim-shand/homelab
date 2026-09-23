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

# Random Password Generation --------------------------------------------------- #
resource "random_password" "main" {
  count            = var.user_password_enabled ? 1 : 0 # If password is enabled, then create else do not.
  length           = 16
  special          = true
  upper = true
  lower = true
  min_upper = 3
  min_lower = 3
  override_special = "!#%&-_"
}

# Proxmox: Service Account Users --------------------------------------------------- #
resource "proxmox_virtual_environment_user" "main" {
  user_id  = var.user_id
  comment  = "[Managed by Terraform] ${var.user_comment}"
  password = var.user_password_enabled ? random_password.main[0].result : null
  groups   = var.user_groups
}

# Proxmox: Service Account API Token --------------------------------------------------- #
resource "proxmox_user_token" "main" {
  count           = var.user_token_enabled ? 1 : 0 # If token is enabled, then create else do not.
  user_id         = proxmox_virtual_environment_user.main.user_id
  token_name      = "api" # Used to form the connection string (svc-account@pve!api=token_string).
  comment         = "[Managed by Terraform] ${local.formatted_date}"
  privileges_separation = false
  lifecycle {
    ignore_changes = [ comment ] # Ignore for update as timestamp changes each run.
  }
}
