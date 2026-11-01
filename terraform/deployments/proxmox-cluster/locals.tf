# Select only users and groups where 'enabled' flag equals 'true'.
locals {
  pve_iam_groups_enabled = {
    for k, v in var.pve_iam_groups : k => v
    if v.enabled
  }
  pve_iam_users_svc_enabled = {
    for k, v in var.pve_iam_users_svc : k => v
    if v.enabled
  }
}
