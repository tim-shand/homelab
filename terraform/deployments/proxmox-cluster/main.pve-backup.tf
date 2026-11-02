# ========================================================================================================= #
# Proxmox: Backup Configuration
# Description:
# - Manages Proxmox VE Cluster backup schedules and configuration.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/backup_job
# ========================================================================================================= #

# Backup Schedule ----------------------------------------------- #

locals {
  # Build new map of pools to backup, only if backup is enabled.
  pve_backup_pools_enabled = {
    for k,v in var.pve_backup_pools : k => v
    if v.enable
  }
}

resource "proxmox_backup_job" "main" {
  for_each = local.pve_backup_pools_enabled
  id       = each.value.job_name
  comment  = each.value.job_name # Description of the backup job, shown in the Proxmox VE web UI
  schedule = each.value.schedule # Backup schedule in systemd calendar event format.
  storage  = each.value.datastore # The storage identifier for the backup.
  pool     = each.key # Limit backup to guests in the specified pool.
  mode     = "snapshot" # The backup mode (snapshot, suspend, or stop).
  compress = "zstd" # The compression algorithm (0, 1, gzip, lzo, or zstd).
  remove        = true # Whether to remove old backups if there are more than max files.
  repeat_missed = true # Whether to repeat missed backup jobs as soon as possible.
}
