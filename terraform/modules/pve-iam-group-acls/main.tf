# ======================================================== #
# MODULE: Proxmox IAM - Group and ACL Permissions
# DESCRIPTION: Create PVE group and assign role + scope.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/acl
# ======================================================== #

terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
}

# Proxmox: Groups --------------------------------------------------- #
resource "proxmox_virtual_environment_group" "main" {
  for_each = var.pve_iam_groups
  group_id = each.key
  comment  = each.value
}

resource "proxmox_acl" "main" {
  for_each  = var.pve_iam_groups
  group_id  = each.key
  role_id   = each.value.role
  path      = each.value.scope
  propagate = true
}
