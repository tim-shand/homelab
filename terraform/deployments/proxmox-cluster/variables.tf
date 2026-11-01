# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

variable "pve_cluster_options" {
  description = "Define Proxmox cluster options."
  type = object({
    description = string
    language    = string
    keyboard    = string
    mac_prefix  = string
    crs_ha      = string
    next_id = object({
      lower = number
      upper = number
    })
  })
  validation {
    condition     = length(var.pve_cluster_options.mac_prefix) == 8
    error_message = "The value length required is 8 characters."
  }
  validation {
    condition     = can(regex("^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){2}$", var.pve_cluster_options.mac_prefix))
    error_message = "Value must be a valid MAC address prefix (first 3 octets only)."
  }
}

variable "pve_pools" {
  description = "Map of Proxmox cluster pools."
  type        = map(string)
}

variable "pve_iam_groups" {
  description = "Map of objects defining Proxmox groups and permissions."
  type = map(object({
    comment = string
    enabled = string
    acls    = map(string)
  }))
}

variable "pve_iam_users_svc" {
  description = "Map of objects defining Proxmox service accounts and group memberships."
  type = map(object({
    comment          = string
    enabled          = bool
    password_enabled = bool
    token_enabled    = bool
    realm            = string
    groups           = list(string)
  }))
}

# Proxmox: Software Defined Networking ------------------------------------------------- #

variable "pve_sdn_zones_simple" {
  description = "Map of objects defining the simple SDN Zones for Proxmox."
  type = map(object({
    enabled = bool
    mtu     = number
    ipam    = string
  }))
}

variable "pve_sdn_zones_vlan" {
  description = "Map of objects defining the VLAN SDN Zones for Proxmox."
  type = map(object({
    enabled = bool
    mtu     = number
    ipam    = string
  }))
}

variable "pve_sdn_vnets" {
  description = "Object of defined Proxmox SDN VNets to be configured."
  type = map(object({
    alias         = string
    zone_id       = string
    vlan_tag      = number
    isolate_ports = bool
    vlan_aware    = bool
    subnets = map(object({
      cidr_address = string
      gateway      = string
    }))
  }))
}
