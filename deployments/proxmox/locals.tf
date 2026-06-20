# Local Variables ------------------------------------------- #

# Production Proxmox Nodes
# Used to target specific resources to production nodes in the cluster, such as SDN zones.
# locals {
#   pve_nodes_production = {
#     for k,v in var.pve_nodes : # For key, value in variable
#     k => v # Insert existing key and value into new map
#     if v.enabled # Only if value.enabled = true.
#   }
# }

locals {
  pve_nodes_production = [
    for k,v in var.pve_nodes : # For key and value in variable.
    v.hostname # Insert value.hostname into new list.
    if v.enabled # Only if value.enabled = true.
  ]
}
