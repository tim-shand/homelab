output "user_token" {
    description = "Sensitive token value for user account."
    value = proxmox_user_token.main.value # terraform output -json database_password | jq -r '.'
}
