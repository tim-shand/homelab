# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# ========================================================================================================= #

resource "proxmox_sdn_zone_vlan" "vlan" {
    id = "zone_vlan"
    nodes = [local.pve_nodes_prd] # List of production nodes in cluster.
    bridge = var.pve_network.guest.bridge # Use guest bridge for SDN zone.
    mtu = var.pve_network.mtu
}
