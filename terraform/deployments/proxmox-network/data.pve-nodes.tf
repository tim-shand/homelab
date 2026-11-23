# ====================================================================== #
# Data: Proxmox Nodes
# Description:
# - Get Proxmox node details for all Proxmox nodes in cluster.
# - Used by various modules to target specific nodes for deployments.
# ====================================================================== #

# Retrieves information about all available Proxmox VE nodes.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/data-sources/virtual_environment_nodes
data "proxmox_virtual_environment_nodes" "pve_nodes" {}

data "proxmox_virtual_environment_hosts" "pve_nodes" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.pve_nodes.names)
  node_name = each.value
}

locals {
  # Build map of nodes, including their IP addresses and hostnames.
  pve_nodes = {
    for k,v in data.proxmox_virtual_environment_hosts.pve_nodes : k => {
      hostname  = v.entries[1].hostnames[0]
      ipaddress = v.entries[1].address
    }
  }
}
