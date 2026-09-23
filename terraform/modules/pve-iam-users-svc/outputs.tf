# terraform output -json database_password | jq -r '.'

output "user_password" {
    description = "Sensitive token value for user account."
    value = var.user_password_enabled ? random_password.main[0].result : null
}

output "user_token" {
    description = "Sensitive token value for user account."
    value = var.user_token_enabled ? proxmox_user_token.main[0].value : null
}
