# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

variable "pve_api_terraform_user" {
  description = "Proxmox API service account for Terraform."
  type        = string
}

variable "pve_api_terraform_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type        = string
  sensitive   = true
}

variable "pve_nodes" {
  description = "Map of objects defining Proxmox nodes in the cluster."
  type = map(object({
    node_name  = string
    hostname   = string
    production = bool
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

variable "template_ubuntu_id" {
  description = "ID number of the Ubuntu cloud image template created during Proxmox bootstrap."
  type        = string
  default     = "9000"
}

variable "datastore_id" {
  description = "ID of the Proxmox datastore to be used for storing VM disks and cloud images."
  type        = string
  default     = "local" # Default datastore ID for Proxmox, can be overridden by user input.
}

variable "vm_specs" {
  description = "Map of details used to provision the VM."
  type = object({
    name        = string
    description = string
    tags        = list(string)
    vm_cores    = number
    vm_memory   = number
  })
}

variable "vm_networking" {
  description = "Network configuration for the VM."
  type = object({
    domain       = string
    dns_servers  = list(string)
    ipv4_address = string
    ipv4_gateway = string
    vlan_id      = string
  })
}

variable "default_user" {
  description = "Default user for the VM, used for cloud-init configuration."
  type        = string
  default     = "svc-ansible" # Default user for the VM, can be overridden by user input.
}

variable "ssh_key_path" {
  description = "Path to central SSH key directory."
  type        = string
  default     = "../../../files/ssh_keys"
}
