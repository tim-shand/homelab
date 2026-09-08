# Local Variables ------------------------------------------- #

# Production Proxmox Nodes
# Used to target specific resources to production nodes in the cluster, such as SDN zones.

locals {
  # Used to limit deployment of resources to nodes missing.
  pve_nodes_production = [
    for k,v in var.pve_nodes : # For key and value in variable.
    v.node_name # Insert value.hostname into new list.
    if v.production # Only if value.enabled = true.
  ]
}
