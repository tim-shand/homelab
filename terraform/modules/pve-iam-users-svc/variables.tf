variable "user_id" {
    description = "Service account user name ID."
    type = string
    nullable = false
    validation {
        condition     = can(regex("^[a-zA-Z0-9._%+-]+@(pam|pve)$", var.user_id))
        error_message = "Value must be a valid Proxmox user format (username@realm)."
    }
}

variable "user_comment" {
    description = "Service account user description."
    type = string
    nullable = false
}

variable "user_groups" {
    description = "List of groups to add the user into."
    type = list(string)
    nullable = false
}

variable "user_password_enabled" {
    description = "Enable or disable random password generation for user account."
    type = bool
    default = false
}

variable "user_token_enabled" {
    description = "Enable or disable API token generation for user account."
    type = bool
    default = true
}