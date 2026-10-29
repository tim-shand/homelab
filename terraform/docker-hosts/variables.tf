# variable "cpu_cores" {
#   description = "Number of CPU cores to assign to Docker hosts."
#   type = number
#   default = 2
# }

# variable "memory_mb" {
#   description = "Amount of memory to assign in MB."
#   type = number
#   default = 2048
# }

# variable "disk_size_gb" {
#   description = "Size of disk for Docker hosts."
#   type = number
#   default = 16
# }

variable "disk_datastore_prd" {
  description = "Location of datastore to store VM disks."
  type = string
  default = "local-lvm"
}

variable "disk_datastore_dev" {
  description = "Location of datastore to store VM disks."
  type = string
  default = "local-lvm"
}

# variable "dns_domain" {
#   description = "Name of the DNS domain to use with Cloud-Init setup."
#   type = string
# }

variable "docker_hosts" {
  type = map(object({
    enabled         = bool
    env_prd         = bool
    pve_node        = string
    template_id     = number
    pool_id         = optional(string,null)
    network_bridge  = string
    ip_address      = string
    gateway_address = string
    dns_servers     = list(string)
    dns_domain      = string
  }))
}
