variable "group_name" {
  description = "Proxmox group name."
  type        = string
}

variable "group_comment" {
  description = "Proxmox group description (comment)."
  type        = string
}

variable "group_acls" {
  description = "Object defining the roles and scopes (paths) for the group permissions."
  type        = map(string)
}
