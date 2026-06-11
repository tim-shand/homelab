# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

variable "pve_auth_api_token" {
    description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
    type = string
    sensitive = true
}

variable "pve_nodes" {
    description = "Map of Proxmox nodes in the cluster, with details for API access and production status."
    type = map(object({
        hostname    = string
        ip_address  = string
        production  = bool
    }))
}

variable "pve_network" {
    description = "Map of Proxmox network configurations for the cluster and guest VMs."
    type = map(object({
        mtu = number
        cluster = object({
            nic = string
            bridge = string
        })
        guest = object({
            nic = string
            bridge = string
        })
    }))
}

variable "pve_pools" {
    description = "Map of Proxmox resource pools to create, with pool ID and comment for each pool."
    type = map(object({
        pool_id = string
        comment = string
    }))
}

# variable "pve_sdn_zones" {
#     description = "Map of Proxmox SDN zones to create, with configuration for each zone."
#     type = map(object({
#         id = string
#         nodes = optional(list(string))
#         bridge = string
#         mtu = number
#         # Optional Attributes. Only required if using Proxmox IPAM for DHCP and DNS management.
#         # Ignore for OPNsense DHCP and DNS management.
#         dns = optional(string)
#         dns_zone = optional(string)
#         ipam = optional(string)
#         reverse_dns = optional(string)
#     }))
# }
