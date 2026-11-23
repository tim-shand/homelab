# ========================================================================================================= #
# Proxmox: Storage Configuration
# Description:
# - Manages Proxmox VE storage configuration for remote shares and local directories.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/storage_nfs
# ========================================================================================================= #

# Storage: Shared-NFS --------------------------------------- #

# locals {
#   datastore = {
#     for k in data.proxmox_virtual_environment_nodes.pve_nodes.names : k => {
#       local_iso  = [for ds in data.proxmox_datastores.pve_nodes[k].datastores : ds.id if ds.active && contains(ds.content_types, "iso")][0]
#       zfs_pool   = [for ds in data.proxmox_datastores.pve_nodes[k].datastores : ds.id if ds.active && ds.type == "zfspool"][0]
#       shared     = [for ds in data.proxmox_datastores.pve_nodes[k].datastores : ds.id if ds.active && ds.type == "zfspool"][0]
#     }
#   }
# }

locals {
  storage_nfs_enabled = {
    for k,v in var.pve_storage_nfs : k => v
    if v.enabled
  }
}

resource "proxmox_storage_nfs" "main" {
  for_each = local.storage_nfs_enabled
  id       = each.key       # The unique identifier of the storage.
  nodes    = each.value.all_nodes ? [for k,v in local.pve_nodes : k] : [for node in each.value.nodes : node] # If all nodes, list all nodes
  server   = each.value.server       # The IP address or DNS name of the NFS server.
  export   = each.value.export       # The path of the NFS export.
  options       = each.value.options # The options to pass to the NFS service.
  preallocation = "metadata"         # The preallocation mode for raw and qcow2 images.
  content       = each.value.content
  backups {
    max_protected_backups = each.value.backups.max_protected_backups  # The maximum number of protected backups per guest.
    keep_hourly           = each.value.backups.keep_hourly # The number of hourly backups to keep. Older backups will be removed.
    keep_daily            = each.value.backups.keep_daily
    keep_weekly           = each.value.backups.keep_weekly
    keep_monthly          = each.value.backups.keep_monthly
  }
}
