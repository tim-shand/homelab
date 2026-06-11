# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# ========================================================================================================= #

resource "proxmox_sdn_zone_vlan" "vlan_zone" {
    id = "ZoneVLAN"
    nodes = [local.pve_nodes_prd] # List of production nodes in cluster.
    bridge = "vmbr1"
    mtu = 1500
}
