# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# - Proxmox SDN Hierarchy: Zone --> VNet --> Subnet
# ========================================================================================================= #

# Runs first, applies any pre-existing pending state (manual, interrupted, failed).
resource "proxmox_sdn_applier" "init" {}

# SDN: Zones ================================================================== #

# Zone: Internal --------------------------------- #
resource "proxmox_sdn_zone_simple" "znint" {
  id = "znint" # Max 8 characters, no symbols.
  #nodes     = local.pve_nodes_production # Comment out to add to all nodes in cluster.
  mtu  = 1500  # Default 1550 for VLAN zones.
  ipam = "pve" # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.init # Runs first, applies any pre-existing pending state (manual, interrupted, failed). 
  ]
}

# Zone: VLAN --------------------------------- #
resource "proxmox_sdn_zone_vlan" "znvlan" {
  id     = "znvlan"                                                  # Max 8 characters, no symbols.
  nodes  = [for node in local.pve_nodes_production : node.node_name] # Remove line to add to all nodes.
  bridge = var.pve_default_bridge_guest                              # VLAN aware bridge for workloads.
  mtu    = 1500                                                      # Default 1550 for VLAN zones.
  ipam   = "pve"                                                     # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.init # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
  ]
}

# SDN: VNets ================================================================== #
# Deploy VNets, VLANs and subnets using custom module.
module "pve_sdn_vnet" {
  source        = "../../modules/pve-sdn-vnet"
  for_each      = var.pve_sdn_vnets               # Loop each defined VNet and it's subnets from variables.
  zone_id       = proxmox_sdn_zone_vlan.znvlan.id # Zone ID from above.
  vnet_id       = each.key                        # Use looped key value for name.
  vlan_tag      = each.value.vlan_tag             # VLAN tag for VNet, used for traffic isolation and segmentation.
  isolate_ports = each.value.isolate_ports        # True/False: Guests can only send traffic to non-isolated bridge-ports (the bridge itself).
  vlan_aware    = each.value.vlan_aware           # Disable for VNet level tagging. Enables vlan-aware on interface, requiring configuration in the guest.
  subnets       = each.value.subnets              # Map of subnets to create in the VNet.
  depends_on = [
    proxmox_sdn_applier.init # Runs first, applies any pre-existing pending state (manual, interrupted, failed). 
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
      proxmox_sdn_zone_simple.znint,
      proxmox_sdn_zone_vlan.znvlan,
      terraform_data.vnet_trigger
    ]
  }
  depends_on = [
    proxmox_sdn_zone_simple.znint,
    proxmox_sdn_zone_vlan.znvlan,
    module.pve_sdn_vnet
  ]
}
