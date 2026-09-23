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
  type        = string
}

variable "pve_api_terraform_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type        = string
  sensitive   = true
}

variable "pve_cluster_options" {
  description = "Define Proxmox cluster options."
  type = object({
    description = string
    email_from  = string
    language    = string
    keyboard    = string
    mac_prefix  = string
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
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.pve_cluster_options.email_from))
    error_message = "Value must be a valid email address format."
  }
  validation {
    condition     = can(regex("^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){2}$", var.pve_cluster_options.mac_prefix))
    error_message = "Value must be a valid MAC address prefix (first 3 octets only)."
  }
}

variable "pve_nodes" {
  description = "Map of objects defining Proxmox nodes in the cluster."
  type = map(object({
    node_name   = string
    description = string
    hostname    = string
    production  = bool
    network = object({
      ip_address = string
      cluster = object({
        interface = string
        bridge    = string
      })
      guest = object({
        interface = string
        bridge    = string
      })
    })
  }))
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

variable "pve_sdn_vnets" {
  description = "Object of defined Proxmox SDN VNets to be configured."
  type = map(object({
    id            = string
    vlan_tag      = number
    isolate_ports = bool
    vlan_aware    = bool
    subnets = map(object({
      cidr_address = string
      gateway      = string
    }))
  }))
}
