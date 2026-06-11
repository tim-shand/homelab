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

variable "pve_hosts" {
    description = "Map of Proxmox hosts in the cluster, with details for API access and network configuration."
    type = map(object({
        hostname    = string
        dns_domain  = string
        ip_address  = string
        network = object({
            pve = object({
                nic_name    = string
                bridge_name = string
            })
            vms = object({
                nic_name    = string
                bridge_name = string
            })
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