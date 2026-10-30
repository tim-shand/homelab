output "vm_id" {
  description = "Proxmox VM ID."
  value       = proxmox_virtual_environment_vm.main.vm_id
}

output "hostname" {
  description = "VM hostname."
  value       = proxmox_virtual_environment_vm.main.name
}

output "node_name" {
  description = "Proxmox node hosting the VM."
  value       = proxmox_virtual_environment_vm.main.node_name
}

output "ip_address" {
  description = "Configured IPv4 address."
  value       = split("/", var.ip_address)[0]
}

output "ansible_user" {
  description = "Default Ansible user name."
  value       = var.ansible_user
}
