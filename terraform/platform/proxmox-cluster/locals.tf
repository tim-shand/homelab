# Production Proxmox Nodes ------------------------------------------- #
# Used to target specific resources to production nodes in the cluster, such as SDN zones.
locals {
  # Used to limit deployment of resources to nodes missing.
  pve_nodes_production = {
    for k,v in var.pve_nodes : k => v
    if v.production # Only if value.enabled = true.
  }
}

# Proxmox: IAM - Users and Groups ------------------------------------------- #
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
