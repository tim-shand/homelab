# ====================================================================== #
# Proxmox: Resource Pools
# Description:
# - Configuration for defining resource for managing VM pools.
# ====================================================================== #

# Resource: Proxmox Virtual Environment Pools ------------------------------------------- #
resource "proxmox_virtual_environment_pool" "pve_pools" {
    for_each = var.pve_pools
    pool_id  = each.value.pool_id
    comment  = each.value.comment
}
