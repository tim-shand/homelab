# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

# Proxmox: VM Templates --------------------------------------------- #

variable "vm_templates" {
  description = "Map of objects containing the Proxmox VM template parameters."
  type = map(object({
    template_id = number
    description = string
    enabled = bool
    src_url = string
    dst_file = string
  }))
}
