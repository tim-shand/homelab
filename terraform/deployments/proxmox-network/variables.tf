# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

# PROXMOX AUTHENTICATION -------------------------------------------- #

variable "pve_api_url" {
  description = "URL string used to connect to Proxmox API. To be passed via commandline or workflow secret."
  type        = string
}

variable "pve_api_user" {
  description = "Proxmox API service account for Terraform."
  type        = string
}

variable "pve_api_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type        = string
  sensitive   = true
}

# / --------------------------------------------------------- #

# Proxmox: Software Defined Networking ------------------------------------------------- #

variable "pve_network_bridges" {
  description = "Map of default Proxmox networking configuration."
  type = object({
    cluster = string
    guests  = string
  })
}

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
