# ====================================================================== #
# Proxmox: Resource Pools
# Description:
# - Configuration for defining resource pools in PRoxmox cluster.
# ====================================================================== #

# Proxmox: Resource Pools ------------------------------------------- #

resource "proxmox_virtual_environment_pool" "mgt" {
    pool_id  = "management"
    comment  = "Management Resources"
}

resource "proxmox_virtual_environment_pool" "prd" {
    pool_id  = "production"
    comment  = "Production Workloads"
}

resource "proxmox_virtual_environment_pool" "dev" {
    pool_id  = "development"
    comment  = "Development Workloads"
}
