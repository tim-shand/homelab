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
  group_id = var.pve_group_name
  comment  = var.pve_group_comment
}

resource "proxmox_acl" "main" {
  for_each  = var.pve_group_acls
  group_id  = var.pve_group_name
  role_id   = each.key
  path      = each.value
  propagate = true
}
