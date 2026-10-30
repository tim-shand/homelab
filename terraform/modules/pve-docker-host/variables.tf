# General ------------------------------------------------ #

variable "hostname" {
    description = "Hostname of the VM."
    type = string
    validation {
        condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.hostname))
        error_message = "Host name must only contain lowercase letters, numbers and hyphens."
    }
}

variable "pve_node" {
  description = "Object defining the target Proxmox node to deploy VM."
  type = object({
    node_id = string
    node_name   = string
    description = string
    datastore_img = string
    datastore_vms = string
    ip_address = string
  })
}

variable "description" {
    description = "Description appended to the VM after default banner message."
    type        = string
    default     = "Docker Host"
}

variable "tags" {
    description = "Proxmox VM tags."
    type        = list(string)
    default     = []
}

variable "pool_id" {
    description = "Optional value of Pool ID to assign VM to."
    type = string
    nullable = true
}

variable "start_on_boot" {
  description = "Start the VM automatically when the Proxmox node boots."
  type        = bool
  default     = true
}

variable "start_after_creation" {
  description = "Whether the VM should be started after creation."
  type        = bool
  default     = true
}

# Compute ------------------------------------------------ #

variable "cpu_cores" {
    description = "Number of CPU cores."
    type        = number
    default     = 2
}

variable "memory_mb" {
    description = "Memory in MB (4096)."
    type        = number
    default     = 1024
}

variable "disk_datastore" {
    description = "Datastore used for the VM disk."
    type        = string
    default     = "local-lvm"
}

variable "disk_size_gb" {
    description = "Additional disk size in GB."
    type        = number
    default     = 16
}

variable "data_disks" {
  description = "Map of additional disks to add to VM (disk1 = 32)."
  type = map(number)
}

# Network ------------------------------------------------ #

variable "network_bridge" {
  description = "Proxmox network bridge (bridge, VNet, VLAN)."
  type        = string
  default     = "vmbr1"
}

variable "ip_address" {
  description = "Static IPv4 address including CIDR prefix."
  type        = string
}

variable "gateway_address" {
  description = "IPv4 default gateway address."
  type        = string
}

variable "dns_servers" {
  description = "Define the DNS servers."
  type        = list(string)
  default     = []
}

variable "dns_domain" {
  description = "Define the DNS search domain."
  type        = string
  default     = null
}

# User Account ------------------------------------------------ #

variable "ansible_user" {
  description = "Initial user account for Ansible account."
  type        = string
  default     = "svc-ansible"
}

variable "ansible_ssh_public_key" {
  description = "SSH public key installed for the Ansible user."
  type        = string
  sensitive   = true
}
