# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

# Proxmox: VM Templates --------------------------------------------- #

variable "vm_templates" {
  description = "Map of objects containing the Proxmox VM template parameters."
  type = map(object({
    description = string
    enabled = bool # Enable/disable the template globally.
    maintenance_mode = bool # Set to 'enable' to convert back to VM for maintenance.
    src_url = string
    dst_file = string
    network_bridge = string
    vm_ids = map(string) # VM IDs per Proxmox node.
  }))
}
