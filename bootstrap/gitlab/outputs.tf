output "gitlab_ip" {
  description = "GitLab container IP address"
  value       = var.container_config.network.ipv4
}

output "gitlab_ssh" {
  description = "SSH connection string"
  value       = "ssh root@${split("/", var.container_config.network.ipv4)[0]}"
}

output "gitlab_vmid" {
  description = "Proxmox VM ID"
  value       = proxmox_virtual_environment_container.gitlab.vm_id
}
