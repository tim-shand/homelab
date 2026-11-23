# terraform -chdir=terraform/platform/proxmox-cluster output -json pve_users_sensitive | jq -r '.'
output "pve_users_sensitive" {
  description = "Output of all created Proxmox users, including sensitive values."
  sensitive   = true
  value = {
    for k, v in module.pve_iam_users_svc : k => v.user_all
  }
}

# output "pve_datastores" {
#   description = "Output of PVE datastores."
#   value = data.proxmox_datastores.pve_nodes
# }
