# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

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
