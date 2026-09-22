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

module "pve_iam_group_acls" {
  source = "../../modules/pve-iam-group-acls"
  for_each = var.pve_iam_groups
  pve_group_name = each.key
  pve_group_comment = each.value.comment
  pve_group_acls = each.value.acls
}