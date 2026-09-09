# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

# variable "pve_auth_api_token" {
#     description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
#     type = string
#     sensitive = true
# }

variable "pve_api_terraform_user" {
  description = "Proxmox API service account for Terraform."
  type    = string
}

variable "pve_api_terraform_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type      = string
  sensitive = true
}

variable "pve_nodes" {
    description = "Map of objects defining Proxmox nodes in the cluster."
    type = map(object({
        node_name   = string
        hostname    = string
        production  = bool
        network = object({
            ip_address = string
            cluster = object({
                interface = string
                bridge = string
            })
            guest = object({
                interface = string
                bridge = string
            })
        })
    }))
}

variable "pve_pools" {
    description = "Map of Proxmox cluster pools."
    type = map(string)
}
