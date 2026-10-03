# variable "template_id" {
#   description = "Template ID of VM to clone."
#   type = number
#   validation {
#     condition = var.template_id >= 100 && var.template_id <= 9999
#     error_message = "Template ID must be between 100 and 9999."
#   }
# }

variable "docker_hosts" {
  type = map(object({
    enabled         = bool
    pve_node        = string
    template_id     = number
    pool_id         = optional(string,null)
    cpu_cores       = number
    memory_mb       = number
    disk_size_gb    = number
    disk_datastore  = string
    network_bridge  = string
    ip_address      = string
    gateway_address = string
    dns_servers     = optional(list(string),[])
    dns_domain      = optional(string,null)
  }))
}
