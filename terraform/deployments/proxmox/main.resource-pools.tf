# Resource Pools --------------------------------------------------------------#
# Import: `terraform import proxmox_virtual_environment_pool.pool-1 pool-1`
resource "proxmox_virtual_environment_pool" "pool_templates" {
  pool_id = "Templates"
  comment = "VM templates."
}

resource "proxmox_virtual_environment_pool" "pool_management" {
  pool_id = "Management"
  comment = "Servers used for management purposes."
}

resource "proxmox_virtual_environment_pool" "pool_production" {
  pool_id = "Production"
  comment = "Production servers."
}
