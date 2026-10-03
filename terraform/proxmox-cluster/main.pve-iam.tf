# ============================================================================================================ #
# Proxmox: Identity and Access Management
# Description:
# - Manages Proxmox VE User, Groups and Permissions.
# - Notes: https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_group
# - Export Tokens: terraform -chdir=./terraform/platform/proxmox-cluster output -json pve_users_sensitive | jq -r '.'
# ============================================================================================================ #

# Proxmox: Groups --------------------------------------------------- #
module "pve_iam_group_acls" {
  source        = "../../modules/pve-iam-group-acls"
  for_each      = local.pve_iam_groups_enabled
  group_name    = each.key
  group_comment = each.value.comment
  group_acls    = each.value.acls
}

# Proxmox: Service Account Users --------------------------------------------------- #
module "pve_iam_users_svc" {
  source                = "../../modules/pve-iam-users-svc"
  for_each              = local.pve_iam_users_svc_enabled
  user_id               = "${each.key}@${each.value.realm}"
  user_comment          = each.value.comment
  user_password_enabled = each.value.password_enabled
  user_token_enabled    = each.value.token_enabled
  user_groups           = each.value.groups
  depends_on            = [module.pve_iam_group_acls]
}
