variable "user_id" {
    description = "Service account user name ID."
    type = string
    validation {
        condition     = can(regex("^[a-zA-Z0-9._%+-]+@(pam|pve)$", var.user_id))
        error_message = "Value must be a valid Proxmox user format (username@realm)."
    }
}

variable "user_comment" {
    description = "Service account user description."
    type = string
}

variable "user_groups" {
    description = "List of groups to add the user into."
    type = list(string)
}
