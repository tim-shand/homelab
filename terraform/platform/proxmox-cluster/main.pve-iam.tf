# ========================================================================================================= #
# Proxmox: Identity and Access Management
# Description:
# - Manages Proxmox VE User, Groups and Permissions.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_group
# ========================================================================================================= #

# # Proxmox: Groups --------------------------------------------------- #
# resource "proxmox_virtual_environment_group" "main" {
#   for_each = var.pve_iam_groups
#   group_id = each.key
#   comment  = each.value
# }
