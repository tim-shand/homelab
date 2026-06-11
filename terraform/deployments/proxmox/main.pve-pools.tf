# ====================================================================== #
# Proxmox: Resource Pools
# Description:
# - Configuration for defining resource for managing VM pools.
# ====================================================================== #

# Resource: Proxmox Virtual Environment Pool ------------------------------------------- #
resource "proxmox_virtual_environment_pool" "operations_pool" {
    for_each = var.pve_pools
    pool_id = each.value.pool_id
    comment = each.value.comment
}
