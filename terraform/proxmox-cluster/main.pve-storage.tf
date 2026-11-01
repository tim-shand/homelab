# ========================================================================================================= #
# Proxmox: Storage
# Description:
# - Manages Proxmox VE Cluster storage configuration.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/storage_cifs
# ========================================================================================================= #

# Proxmox: Storage - SMB/CIFS ------------------------------- #
# !!! Removed: Due to issues with mounting CIFS on VM - TBC.

# resource "proxmox_storage_cifs" "main" {
#   id       = "smb-shared"
#   #nodes    = ["pve"]
#   disable  = false # Whether the storage is disabled.
#   nodes    = [for k,v in var.pve_nodes : v.node_name ]
#   preallocation            = "metadata" # The preallocation mode for raw and qcow2 images.
#   snapshot_as_volume_chain = true # Enable support for creating snapshots through volume backing-chains.
#   content = [
#     "backup",   # VM/container backups.
#     "images",   # Disk images.
#     "import",   # VM disk images for import.
#     "iso",      # ISO file images.
#     "snippets", # Cloud-init, hook scripts etc.
#     "vztmpl"    # Container templates.
#   ]

#   # Server Config / Authentication
#   server           = var.pve_storage_smb_config.server
#   share            = var.pve_storage_smb_config.share_name
#   subdirectory     = var.pve_storage_smb_config.sub_directory # A subdirectory to mount within the share.
#   #create_base_path = true # Create the base directory if it doesn't exist.
#   create_subdirs   = true # Populate the directory with the default structure.
#   username         = var.pve_storage_smb_config.username
#   password         = var.pve_storage_smb_password
#   domain           = var.pve_storage_smb_config.domain # The SMB/CIFS domain.

#   backups {
#     max_protected_backups = 5
#     keep_daily            = 7
#   }
# }
