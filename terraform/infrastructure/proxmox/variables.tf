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
        nic = string
        bridge = string
        #mtu = number
    }))
}

# variable "pve_pools" {
#     description = "Object of Proxmox cluster pools."
#     type = object({
#         name= string
#         comment = string
#     })
# }

variable "pve_pools" {
    description = "Map of Proxmox cluster pools."
    type = map(string)
}
