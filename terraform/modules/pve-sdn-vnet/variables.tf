variable "vnet_id" {
  description = "Name of VNet to create in Proxmox."
  type        = string
  validation {
    condition     = length(var.vnet_id) <= 8
    error_message = "The value length is a max of 8 characters."
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.vnet_id))
    error_message = "The value must contain only alphanumeric characters with no spaces or special characters."
  }
}

variable "zone_id" {
  description = "ID value of the target VLAN zone."
  type        = string
  validation {
    condition     = length(var.zone_id) <= 8
    error_message = "The value length is a max of 8 characters."
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.zone_id))
    error_message = "The value must contain only alphanumeric characters with no spaces or special characters."
  }
}

variable "vlan_tag" {
  description = "Number value of the VLAN tag."
  type        = number
  validation {
    condition     = var.vlan_tag <= 4094
    error_message = "The value length is a max of 8 characters."
  }
}

variable "subnets" {
  description = "Map of subnet objects."
  type = map(object({
    cidr_address = string
    gateway      = string
  }))
}

variable "isolate_ports" {
  description = "Boolean value to determine port access between nodes in VNet."
  type        = bool
  default     = false
}

variable "vlan_aware" {
  description = "Boolean value to determine if the VNet itself is VLAN aware."
  type        = bool
  default     = false
}
