# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# ========================================================================================================= #

# PVE SDN Applier --------------------------------- #
# Used to trigger updates to the Proxmox SDN configuration when changes are made to the SDN zones or VNets. 
# SDN configuration is applied to the Proxmox cluster without requiring manual effort (click 'Apply' button).
resource "proxmox_sdn_applier" "final" {
    lifecycle {
        replace_triggered_by = [
            proxmox_sdn_zone_vlan.vlan,
            proxmox_sdn_vnet.vlan10,
        ]
    }
    depends_on = [
        proxmox_sdn_zone_vlan.vlan,
        proxmox_sdn_vnet.vlan10,
  ]
}

# Zones --------------------------------- #

resource "proxmox_sdn_zone_vlan" "vlan" {
    id = "zonevlan"
    #nodes   = local.pve_nodes_prd # List of production nodes in cluster.
    bridge  = var.pve_network.guest.bridge # Use guest bridge for SDN zone.
    mtu     = var.pve_network.guest.mtu
}

# VNets --------------------------------- #

resource "proxmox_sdn_vnet" "vlan10" {
  id            = "vlan10"
  zone          = proxmox_sdn_zone_vlan.vlan.id
  alias         = "mgt10" # VNet alias, used for identification and management in Proxmox UI.
  tag           = 10 # VLAN tag for this VNet, used for traffic isolation and segmentation.
  isolate_ports = false # True/False: Whether to isolate ports in this VNet. Guests can only send traffic to non-isolated bridge-ports, which is the bridge itself.
  vlan_aware    = false # Enables vlan-aware option on the interface, enabling configuration in the guest. Disable for VNet level tagging.
}
