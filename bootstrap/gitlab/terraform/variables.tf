# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

variable "pve_auth_api_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type        = string
  sensitive   = true
}

variable "pve_nodes" {
  description = "Map of Proxmox nodes in the cluster, with details for API access and production status."
  type = map(object({
    hostname   = string
    ip_address = string
    production = bool
  }))
}

variable "pve_network" {
  description = "Map of Proxmox network configurations for the cluster and guest VMs."
  type = map(object({
    nic    = string
    bridge = string
    mtu    = number
  }))
}

variable "ubuntu_dist_name" {
  description = "Name of Ubuntu distribution to be used for the cloud image. Used to form strings."
  type        = string
  default     = "resolute"
}

variable "datastore_id" {
  description = "ID of the Proxmox datastore to be used for storing VM disks and cloud images."
  type        = string
  default     = "local" # Default datastore ID for Proxmox, can be overridden by user input.
}

variable "vm_networking" {
  description = "Network configuration for the GitLab VM."
  type = object({
    bridge      = string
    domain      = string
    dns_servers = list(string)
    ipv4 = object({
      address = string
      gateway = string
    })
  })
}

variable "default_user" {
  description = "Default user for the VM, used for cloud-init configuration."
  type        = string
  default     = "linuxadmin"
}