# output "pve_nodes" {
#   description = "Output of PVE nodes."
#   value = data.proxmox_virtual_environment_nodes.pve_nodes.names
# }

output "pve_hosts_details" {
  value = local.pve_node_details
}

# output "pve_datastores" {
#   description = "Output of PVE datastores."
#   value = data.proxmox_datastores.pve_nodes
# }

# output "pve_groups" {
#   description = "Output of all groups created in Proxmox."
#   value = {
#     for k, v in module.pve_iam_group_acls : k => v.group_acls
#   }
# }

# terraform -chdir=terraform/platform/proxmox-cluster output -json pve_users_sensitive | jq -r '.'
output "pve_users_sensitive" {
  description = "Output of all created Proxmox users, including sensitive values."
  sensitive   = true
  value = {
    for k, v in module.pve_iam_users_svc : k => v.user_all
  }
}
