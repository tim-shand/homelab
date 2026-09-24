variable "src_img_url" {
  description = "Full URL string for source image file."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^https?://[a-zA-Z0-9\\-\\.]+(?:\\:[0-9]+)?(?:/.*)?$", var.src_img_url))
    error_message = "Value must be a valid URL string."
  }
}

variable "dst_img_file" {
  description = "String for final destination image file name."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.dst_img_file))
    error_message = "Value must only contain alpha-numeric characters, periods, underscores or dashes."
  }
}

variable "datastore_id_img" {
  description = "ID name of the datastore to hold image files."
  type = string
  default = "local"
}

variable "datastore_id_vms" {
  description = "ID name of the datastore to hold VMs and templates."
  type = string
  default = "local-lvm"
}

variable "pve_node" {
  description = "Name of the Proxmox node to download image and create template."
  type = string
  nullable = false
}

variable "template_id" {
  description = "Numeric value of the intended VM template."
  type = number
  validation {
    condition = var.template_id >=100 && var.template_id <=9999
    error_message = "Template ID must be between 100 and 9999."
  }
}

variable "description" {
  description = "Description of the template."
  type = string
}

variable "nic_bridge" {
  description = "String value of the network interface bridge name on the host."
  type = string
  nullable = false
}