variable "management_hosts" {
  type = map(object({
    enabled         = bool
    description     = string
    tags            = list(string)
    pve_node        = string
    pool_id         = string
    cpu_cores       = number
    memory_mb       = number
    disk_size_gb    = number
    network_bridge  = string
    ip_address      = string
    gateway_address = string
    dns_servers     = list(string)
    dns_domain      = string
    datastore_id    = string
    data_disks      = optional(map(number),null)
  }))
}
