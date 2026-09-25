# =============================================================== #
# VARIABLES: Proxmox - Software Defined Networking
# =============================================================== #

# Proxmox SDN: Zones (Simple) -------------------------------------- #
pve_sdn_zones_simple = {
    "zn0intl" = {
        enabled = true
        mtu     = 1500
        ipam    = "pve"
    }
}

# Proxmox SDN: Zones (VLAN) -------------------------------------- #
pve_sdn_zones_vlan = {
    "zn0vlan" = {
        enabled = true
        mtu     = 1500
        ipam    = "pve"
    }
}

# Proxmox SDN: VNets -------------------------------------- #
pve_sdn_vnets = {
    "vlan10" = {
        alias   = "mgt10"
        zone_id = "zn0vlan"        
        vlan_tag      = 10 # Set to use this tag value at the VNet level, rather than individual VMs.
        isolate_ports = false # If enabled, will prevent comms between devices on same VNet.
        vlan_aware    = false # Set to false, with 'vlan_tag' defined to force whole VNet to use VLAN tagging.
        subnets = {
            "mgt10_1" = {
                cidr_address = "10.0.10.0/24"
                gateway      = "10.0.10.254"
            }
        }
    }
    "vlan20" = {
        alias   = "svr20"
        zone_id = "zn0vlan"
        vlan_tag      = 20
        isolate_ports = false
        vlan_aware    = false
        subnets = {
            "svr20_1" = {
                cidr_address = "10.0.20.0/24"
                gateway      = "10.0.20.254"
            }
        }
    }
}