# ========================================================================================================= #
# Proxmox: SDN (Zones)
# Description:
# - Define and deploy SDN zones into Proxmox cluster.
# ========================================================================================================= #

# SDN - Zone: Simple ------------------------------------------------------- #
# Create an isolated VNet bridge. This bridge is not linked to a physical interface.
# VM traffic is only local on each the node. It can be used in NAT or routed setups.

resource "proxmox_sdn_zone_simple" "main" {
  for_each = var.pve_sdn_zones_simple
  id       = each.key                 # Max 8 characters, no symbols.
  mtu      = each.value.mtu           # Default 1550 for VLAN zones.
  ipam     = each.value.ipam          # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.init          # Runs first, applies any pre-existing pending state (manual, interrupted, failed). 
  ]
}

# SDN - Zone: VLAN --------------------------------------------------------- #
# Uses an existing local Linux or OVS bridge to connect to the node's physical interface. 
# Uses VLAN tagging defined at the VNet level to isolate the network segments. Allows connectivity of VMs between different nodes.

resource "proxmox_sdn_zone_vlan" "main" {
  for_each  = var.pve_sdn_zones_vlan
  id       = each.key                       # Max 8 characters, no symbols.
  bridge   = var.pve_network_bridges.guests # Assign to guest workload bridge, separate from cluster bridge.
  mtu      = each.value.mtu                 # Default 1550 for VLAN zones.
  ipam     = each.value.ipam                # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.init                # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
  ]
}
