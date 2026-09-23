# terraform output -json database_password | jq -r '.'

output "user_safe" {
  description = "Output of user details, safe details only."
  value = {
    user_id          = proxmox_virtual_environment_user.main.user_id
    comment          = proxmox_virtual_environment_user.main.comment
    groups           = proxmox_virtual_environment_user.main.groups
    token_enabled    = var.user_token_enabled
    token_name       = var.user_token_enabled ? proxmox_user_token.main[0].token_name : null
    password_enabled = var.user_password_enabled
  }
}

output "user_all" {
  description = "Output of user details, all including sensitive."
  value = {
    user_id          = proxmox_virtual_environment_user.main.user_id
    comment          = proxmox_virtual_environment_user.main.comment
    groups           = proxmox_virtual_environment_user.main.groups
    token_enabled    = var.user_token_enabled
    token_name       = var.user_token_enabled ? proxmox_user_token.main[0].token_name : null
    token_value      = var.user_token_enabled ? proxmox_user_token.main[0].value : null
    password_enabled = var.user_password_enabled
    password_value   = var.user_token_enabled ? proxmox_virtual_environment_user.main.password : null
  }
}

output "user_password" {
  description = "Sensitive token value for user account."
  value       = var.user_password_enabled ? random_password.main[0].result : null
}

output "user_token" {
  description = "Sensitive token value for user account."
  value       = var.user_token_enabled ? proxmox_user_token.main[0].value : null
}
