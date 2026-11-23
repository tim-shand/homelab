

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


