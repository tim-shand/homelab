# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# - Proxmox SDN Hierarchy: Zone --> VNet --> Subnet
# ========================================================================================================= #

# Runs first, applies any pre-existing pending state (manual, interrupted, failed).
resource "proxmox_sdn_applier" "init" {}

# Zone: Simple ------------------------------------------------------- #

resource "proxmox_sdn_zone_simple" "main" {
  for_each = var.pve_sdn_zones_simple
  id       = each.key # Max 8 characters, no symbols.
  mtu      = each.value.mtu  # Default 1550 for VLAN zones.
  ipam     = each.value.ipam # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.init # Runs first, applies any pre-existing pending state (manual, interrupted, failed). 
  ]
}

# Zone: VLAN ------------------------------------------------------- #
resource "proxmox_sdn_zone_vlan" "main" {
  for_each  = var.pve_sdn_zones_vlan
  id       = each.key # Max 8 characters, no symbols.
  bridge   = var.pve_network.bridge_guest # Assign to guest workload bridge.
  mtu      = each.value.mtu  # Default 1550 for VLAN zones.
  ipam     = each.value.ipam # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.init # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
  ]
}

# SDN: VNets ================================================================== #
# Deploy VNets, VLANs and subnets using custom module.
module "pve_sdn_vnet" {
  source        = "../../modules/pve-sdn-vnet"
  for_each      = var.pve_sdn_vnets               # Loop each defined VNet and it's subnets from variables.
  zone_id       = each.value.zone_id
  vnet_id       = each.key                        # Use looped key value for name.
  vlan_tag      = each.value.vlan_tag             # VLAN tag for VNet, used for traffic isolation and segmentation.
  isolate_ports = each.value.isolate_ports        # True/False: Guests can only send traffic to non-isolated bridge-ports (the bridge itself).
  vlan_aware    = each.value.vlan_aware           # Disable for VNet level tagging. Enables vlan-aware on interface, requiring configuration in the guest.
  subnets       = each.value.subnets              # Map of subnets to create in the VNet.
  depends_on = [
    proxmox_sdn_applier.init, # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
    proxmox_sdn_zone_simple.main,
    proxmox_sdn_zone_vlan.main
  ]
}

# SDN Appliers ================================================================== #
# Used to trigger updates to the Proxmox SDN configuration when changes are made to zones or VNets. 
# SDN configuration is applied to the Proxmox cluster without manual effort (clicking 'Apply' button).

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
