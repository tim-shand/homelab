# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# - Proxmox SDN Hierarchy: Zone --> VNet --> Subnet
# ========================================================================================================= #

# SDN: Zones ================================================================== #

# Internal Zone --------------------------------- #
resource "proxmox_sdn_zone_simple" "znintnl" {
  id        = "znvlan" # Max 8 characters, no symbols.
  #nodes     = local.pve_nodes_production # Comment out to add to all nodes in cluster.
  mtu       = 1500     # Default 1550 for VLAN zones.
  ipam      = "pve"    # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.prep # Runs first, applies any pre-existing pending state (manual, interrupted, failed). 
  ]
}

# VLAN Zone --------------------------------- #
resource "proxmox_sdn_zone_vlan" "znvlan" {
  id        = "znvlan" # Max 8 characters, no symbols.
  nodes     = local.pve_nodes_production # Remove to add to all nodes.
  bridge    = "vmbr1"  # VLAN aware bridge for workloads.
  mtu       = 1500     # Default 1550 for VLAN zones.
  ipam      = "pve"    # Use Proxmox IPAM.
  depends_on = [
    proxmox_sdn_applier.prep # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
  ]
}

# SDN: VNets ================================================================== #

# Production Servers 1 (VLAN20) --------------------------------- #
resource "proxmox_sdn_vnet" "svr20" {
  id            = "svr20"                           # Max 8 characters, no symbols.
  zone          = proxmox_sdn_zone_vlan.znvlan.id   # Zone ID from above.
  alias         = "svr20"                           # VNet alias, used for identification and management in Proxmox UI.
  tag           = 20                                # VLAN tag for VNet, used for traffic isolation and segmentation.
  isolate_ports = false                             # True/False: Guests can only send traffic to non-isolated bridge-ports (the bridge itself).
  vlan_aware    = false                             # Disable for VNet level tagging. Enables vlan-aware on interface, requiring configuration in the guest. 
  depends_on = [
    proxmox_sdn_applier.prep
  ]
}

resource "proxmox_sdn_subnet" "svr20_1" {
  cidr            = "10.0.20.0/24"              # Subnet IP range.
  vnet            = proxmox_sdn_vnet.svr20.id   # VNet ID for target/parent VNet.
  gateway         = "10.0.20.254"               # Network gateway address.
  depends_on = [
    proxmox_sdn_applier.prep # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
  ]
}

# DMZ Network - Internet Only, isolated (VLAN99) --------------------------------- #
resource "proxmox_sdn_vnet" "dmz99" {
  id            = "dmz99"
  zone          = proxmox_sdn_zone_vlan.znvlan.id
  alias         = "dmz99"
  tag           = 99
  isolate_ports = true # Prevent host to host communication (host to bridge only).
  vlan_aware    = false
  depends_on = [
    proxmox_sdn_applier.prep
  ]
}

resource "proxmox_sdn_subnet" "dmz99_1" {
  cidr            = "10.0.99.0/24" # Subnet IP range.
  vnet            = proxmox_sdn_vnet.dmz99.id
  gateway         = "10.0.99.254"
  depends_on = [
    proxmox_sdn_applier.prep
  ]
}

# SDN Appliers ================================================================== #
# Used to trigger updates to the Proxmox SDN configuration when changes are made to zones or VNets. 
# SDN configuration is applied to the Proxmox cluster without manual effort (clicking 'Apply' button).

# Runs first, applies any pre-existing pending state (manual, interrupted, failed).
resource "proxmox_sdn_applier" "prep" {}

# Final SDN apply.
resource "proxmox_sdn_applier" "final" {
  lifecycle {
    replace_triggered_by = [
      proxmox_sdn_zone_simple.znintnl,
      proxmox_sdn_zone_vlan.znvlan,
      proxmox_sdn_vnet.svr20,
      proxmox_sdn_subnet.svr20_1,
      proxmox_sdn_vnet.dmz99,
      proxmox_sdn_subnet.dmz99_1,
    ]
  }
  depends_on = [
    proxmox_sdn_zone_simple.znintnl,
    proxmox_sdn_zone_vlan.znvlan,
    proxmox_sdn_vnet.svr20,
    proxmox_sdn_subnet.svr20_1,
    proxmox_sdn_vnet.dmz99,
    proxmox_sdn_subnet.dmz99_1,
  ]
}
