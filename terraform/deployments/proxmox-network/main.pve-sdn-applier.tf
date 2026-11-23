# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Used to trigger updates to the Proxmox SDN configuration when changes are made to zones or VNets. 
# - SDN configuration is applied to the Proxmox cluster without manual effort (clicking 'Apply' button).
# ========================================================================================================= #

# Runs first, applies any pre-existing pending state (manual, interrupted, failed).
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/sdn_applier
resource "proxmox_sdn_applier" "init" {}

# Create a proxy resource that monitors the VNet module output.
resource "terraform_data" "vnet_trigger" {
  input = module.pve_sdn_vnet
}

# Final SDN apply.
resource "proxmox_sdn_applier" "final" {
  lifecycle {
    replace_triggered_by = [
      proxmox_sdn_zone_simple.main,
      proxmox_sdn_zone_vlan.main,
      terraform_data.vnet_trigger
    ]
  }
  depends_on = [
    proxmox_sdn_zone_simple.main,
    proxmox_sdn_zone_vlan.main,
    module.pve_sdn_vnet
  ]
}
