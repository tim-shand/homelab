# Auth Outputs -------------------------------------------- #

# Output the SSH private key for the Gitea VM.
output "gitvm_private_key" {
  description = "SSH private key for the VM, used for authentication and access."
  value       = tls_private_key.gitvm.private_key_openssh
  sensitive   = true
}

# Output the SSH public key for the Gitea VM.
output "gitvm_public_key" {
  description = "SSH public key for the VM, used for authentication and access."
  value       = tls_private_key.gitvm.public_key_openssh
}

# Output the random password for the default user on the Gitea VM.
# terraform -chdir="./terraform" output -raw gitvm_default_user_password
output "gitvm_default_user_password" {
  description = "Randomly generated password for the default user."
  value       = random_password.gitvm.result
  sensitive   = true
}

# VM Information -------------------------------------------- #

output "gitvm_vm" {
  description = "Network configuration for the VM, including domain, DNS servers, IPv4 address, and gateway."
  value = {
    name         = proxmox_virtual_environment_vm.gitvm.name
    dns_domain   = proxmox_virtual_environment_vm.gitvm.initialization[0].dns[0].domain
    dns_servers  = proxmox_virtual_environment_vm.gitvm.initialization[0].dns[0].servers
    ipv4_address = proxmox_virtual_environment_vm.gitvm.initialization[0].ip_config[0].ipv4[0].address
    ipv4_gateway = proxmox_virtual_environment_vm.gitvm.initialization[0].ip_config[0].ipv4[0].gateway
  }
}

output "ipv4_address" {
  description = "String value of the IPv4 address of the VM."
  value       = split("/", proxmox_virtual_environment_vm.gitvm.initialization[0].ip_config[0].ipv4[0].address)[0]
}

output "default_user" {
  description = "String value of the default user."
  value       = proxmox_virtual_environment_vm.gitvm.initialization[0].user_account[0].username
}

output "default_pass" {
  description = "String value of the default user password (sensitive)."
  value       = proxmox_virtual_environment_vm.gitvm.initialization[0].user_account[0].password
  sensitive   = true
}
