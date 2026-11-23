# Retrieves information about all available Proxmox VE nodes.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/data-sources/virtual_environment_nodes
data "proxmox_virtual_environment_nodes" "pve_nodes" {}

data "proxmox_virtual_environment_hosts" "pve_nodes" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.pve_nodes.names)
  node_name = each.value
}

# Retrieves information about all the datastores available to a specific node (provided by loop).
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/data-sources/datastores
data "proxmox_datastores" "pve_nodes" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.pve_nodes.names)
  node_name = each.value
}

locals {
  pve_node_details = {
    for k,v in data.proxmox_virtual_environment_hosts.pve_nodes : k => {
      hostname  = v.entries[1].hostnames[0]
      ipaddress = v.entries[1].address
    }
  }
}

# locals {
#   datastore = {
#     for k in data.proxmox_virtual_environment_nodes.pve_nodes.names : k => {
#       iso      = [for ds in data.proxmox_virtual_environment_datastores.datastores[node].datastores : ds.id if contains(ds.content_types, "iso")][0]
#       snippets = [for ds in data.proxmox_virtual_environment_datastores.datastores[node].datastores : ds.id if contains(ds.content_types, "snippets")][0]
#       vztmpl   = [for ds in data.proxmox_virtual_environment_datastores.datastores[node].datastores : ds.id if contains(ds.content_types, "vztmpl")][0]
#       images   = [for ds in data.proxmox_virtual_environment_datastores.datastores[node].datastores : ds.id if contains(ds.content_types, "images")][0]
#     }
#   }
# }

# locals {
#   datastore = {
#     for k in data.proxmox_virtual_environment_nodes.pve_nodes.names : k => {
#       local_iso  = [for ds in data.proxmox_datastores.pve_nodes[k].datastores : ds.id if ds.active && contains(ds.content_types, "iso")][0]
#       zfs_pool   = [for ds in data.proxmox_datastores.pve_nodes[k].datastores : ds.id if ds.active && ds.type == "zfspool"][0]
#       shared     = [for ds in data.proxmox_datastores.pve_nodes[k].datastores : ds.id if ds.active && ds.type == "zfspool"][0]
#     }
#   }
# }

# output "datastore_zfs" {
#   value = local.datastore_zfs
# }


