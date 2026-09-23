output "pve_groups" {
  description = "Output of all groups created in Proxmox."
  value = {
    for k, v in module.pve_iam_group_acls : k => v.group_acls
  }
}

output "pve_users_sensitive" {
  description = "Output of all created Proxmox users, including sensitive values."
  sensitive   = true
  value = {
    for k, v in module.pve_iam_users_svc : k => v.user_all
  }
}

output "pve_users_safe" {
  description = "Output of all created Proxmox users, safe values only."
  value = {
    for k, v in module.pve_iam_users_svc : k => v.user_safe
  }
}

output "pve_sdn_vnets_subnets" {
  description = "Output of all VNets and subnets."
  value       = module.pve_sdn_vnet
}
