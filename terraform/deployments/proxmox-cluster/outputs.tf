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

output "pve_backup_jobs" {
  description = "Output map of Proxmox pool-based backup job schedules."
  value = {
    for k,v in proxmox_backup_job.main : k => {
      id            = v.id
      comment       = v.comment
      mode          = v.mode
      pool          = v.pool
      repeat_missed = v.repeat_missed
      schedule      = v.schedule
      storage       = v.storage
    }
  }
}
