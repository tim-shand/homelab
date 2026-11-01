# ========================================================================================================= #
# Proxmox: Backup Configuration
# Description:
# - Manages Proxmox VE Cluster backup schedules and configuration.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/backup_job
# ========================================================================================================= #

# Backup Schedule ----------------------------------------------- #

resource "proxmox_backup_job" "daily_backup" {
  id       = "pve-backup-daily-0200-pool-prd-1"
  schedule = "*-*-* 02:00"
  storage  = var.pve_nodes["node2"].datastore_vms
  all      = true
  mode     = "snapshot"
  compress = "zstd"
}
