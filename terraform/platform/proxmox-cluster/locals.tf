# Production Proxmox Nodes ------------------------------------------- #
# Used to target specific resources to production nodes in the cluster, such as SDN zones.
locals {
  # Used to limit deployment of resources to nodes missing.
  pve_nodes_production = [
    for node in var.pve_nodes : { # For key and value in variable.
      node_name = node.node_name # Insert value.hostname into new list.
      guest_bridge = node.network.guest.bridge # Host bridge used for guest workloads.
    }
    if node.production # Only if value.enabled = true.
  ]
}

# Proxmox: IAM - Users and Groups ------------------------------------------- #
# Select only users and groups where 'enabled' flag equals 'true'.
locals {
  pve_iam_groups_enabled = {
    for k,v in var.pve_iam_groups : k => v
    if v.enabled
  }
  pve_iam_users_svc_enabled = {
    for k,v in var.pve_iam_users_svc : k => v
    if v.enabled
  }
}
