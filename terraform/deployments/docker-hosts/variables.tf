variable "docker_host_config" {
  description = "Define Docker host environment settings."
  type = map(object({
    cpu_cores    = number # Number of CPU cores assigned.
    memory_mb    = number # Memory assigned to VM in MB.
    disk_gb      = number # Size of primary disk in GB.
    datastore_id = string # Target datastore for resources (local-lvm).
    data_disks   = optional(map(number),null)
  }))
  validation {
    # Ensures that the validation condition evaluates to true for every single object in the map.
    condition = alltrue([
      for k,v in var.docker_host_config : v.cpu_cores >= 1
    ])
    error_message = "CPU cores assigned must be greater than, or equal to 1."
  }
  validation {
    # Ensures that the validation condition evaluates to true for every single object in the map.
    condition = alltrue([
      for k,v in var.docker_host_config : v.memory_mb >= 1024
    ])
    error_message = "Memory assigned must be greater than, or equal to 1GB (1024MB)."
  }
  validation {
    # Ensures that the validation condition evaluates to true for every single object in the map.
    condition = alltrue([
      for k,v in var.docker_host_config : v.disk_gb >= 8
    ])
    error_message = "Disk size assigned must be greater than, or equal to 8GB."
  }
}

variable "docker_hosts" {
  type = map(object({
    enabled         = bool
    enable_prod     = bool
    pve_node        = string
    pool_id         = optional(string,null)
    ip_address      = string
    gateway_address = string
    dns_servers     = list(string)
    dns_domain      = string
    network_bridge  = string
  }))
}
