# Auth Outputs -------------------------------------------- #

# Output the SSH private key for the GitLab VM.
output "gitlab_private_key" {
  description = "SSH private key for the GitLab VM, used for authentication and access."
  value       = tls_private_key.gitlab.private_key_openssh
  sensitive   = true
}

# Output the SSH public key for the GitLab VM.
output "gitlab_public_key" {
  description = "SSH public key for the GitLab VM, used for authentication and access."
  value       = tls_private_key.gitlab.public_key_openssh
}

# Output the random password for the default user on the GitLab VM.
# terraform -chdir="./terraform" output -raw gitlab_default_user_password
output "gitlab_default_user_password" {
  description = "Randomly generated password for the default user on the GitLab VM, used for authentication and access."
  value       = random_password.gitlab.result
  sensitive   = true
}

# VM Information -------------------------------------------- #

output "gitlab_vm" {
  description = "Network configuration for the GitLab VM, including domain, DNS servers, IPv4 address, and gateway."
  value = {
    name         = proxmox_virtual_environment_vm.gitlab.name
    dns_domain   = proxmox_virtual_environment_vm.gitlab.initialization[0].dns[0].domain
    dns_servers  = proxmox_virtual_environment_vm.gitlab.initialization[0].dns[0].servers
    ipv4_address = proxmox_virtual_environment_vm.gitlab.initialization[0].ip_config[0].ipv4[0].address
    ipv4_gateway = proxmox_virtual_environment_vm.gitlab.initialization[0].ip_config[0].ipv4[0].gateway
  }
}

output "default_user" {
  description = "String value of the default user."
  value       = proxmox_virtual_environment_vm.gitlab.initialization[0].user_account[0].username
  sensitive   = false
}

output "default_pass" {
  description = "String value of the default user password (sensitive)."
  value       = proxmox_virtual_environment_vm.gitlab.initialization[0].user_account[0].password
  sensitive   = true
}
