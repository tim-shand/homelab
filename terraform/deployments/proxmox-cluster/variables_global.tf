# =============================================================== #
# GLOBAL PROXMOX VARIABLES
# Description:
# - Variable definitions used globally by Terraform deployments.
# - Must be updated in each root module when changes are needed.
# =============================================================== #

# AUTHENTICATION ------------------------------------------- #
variable "pve_api_endpoint_url" {
  description = "URL string used to connect to Proxmox API. To be passed via commandline or workflow secret."
  type        = string
}

variable "pve_api_terraform_user" {
  description = "Proxmox API service account for Terraform."
  type        = string
}

variable "pve_api_terraform_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type        = string
  sensitive   = true
}

variable "vm_default_user" {
  description = "String defining the default user account for VMs."
  type = string
  default = "localadmin"
}

variable "vm_default_pass" {
  description = "Secret string defining the default user password for VMs."
  type = string
  sensitive = true
}

variable "ansible_user" {
  description = "Username of the Ansible service account."
  type = string
  default = "svc-ansible"
}

# PROXMOX CLUSTER ------------------------------------------- #

# variable "pve_nodes" {
#   description = "Map of objects defining Proxmox nodes in the cluster."
#   type = map(object({
#     node_id = string
#     node_name   = string
#     description = string
#     datastore_img = string
#     datastore_vms = string
#     ip_address = string
#   }))
# }

variable "pve_network" {
  description = "Map of default Proxmox networking configuration."
  type = object({
    bridge_cluster = string
    bridge_guest   = string
  })
}
