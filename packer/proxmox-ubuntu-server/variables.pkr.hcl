# Variables: Workflow -------------------------------------- #

# variable "pve_node" {
#   type = string
# }

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

variable "pve_api_packer_user" {
  description = "Proxmox API user account for Packer."
  type    = string
}

variable "pve_api_packer_token" {
  description = "Proxmox API user token for Packer."
  type    = string
}

# Variables: File -------------------------------------- #

variable "vm_id" {
  type = number
  default = 9000
}

variable "os_name" {
  type = string
  default = "Ubuntu"
}

variable "distro_name" {
  type = string
  default = "Resolute"
}

variable "distro_version" {
  type = string
  default = "26.04"
}

variable "default_username" {
  type    = string
  default = "linuxadmin"
}

variable "default_password" {
  type    = string
  default = "changeme123"
}

variable "pve_storage" {
  type = string
  default = "local-lvm"
}

variable "vm_vlan_tag" {
  type = string
  default = "20"
}

variable "iso_checksum" {
  type = string
}
