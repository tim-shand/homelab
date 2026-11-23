# =============================================================== #
# VARIABLES: Proxmox - Software Defined Networking
# =============================================================== #

# Proxmox: Network Bridges -------------------------------------- #
pve_network_bridges = {
    cluster = "vmbr0"
    guests  = "vmbr1"
}

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
    "mgt10" = {
        zone_id = "zn0vlan"        
        vlan_tag      = 10 # Set to use this tag value at the VNet level, rather than individual VMs.
        isolate_ports = false # If enabled, will prevent comms between devices on same VNet.
        vlan_aware    = false # Set to false, with 'vlan_tag' defined to force whole VNet to use VLAN tagging.
        subnets = {
            "mgt10_subnet_01" = {
                cidr_address = "10.0.10.0/24"
                gateway      = "10.0.10.254"
            }
        }
    }
    "svr20" = {
        zone_id = "zn0vlan"
        vlan_tag      = 20
        isolate_ports = false
        vlan_aware    = false
        subnets = {
            "svr20_subnet_01" = {
                cidr_address = "10.0.20.0/24"
                gateway      = "10.0.20.254"
            }
        }
    }
    "lab30" = {
        zone_id = "zn0vlan"
        vlan_tag      = 30
        isolate_ports = false
        vlan_aware    = false
        subnets = {
            "lab30_subnet_01" = {
                cidr_address = "10.0.30.0/24"
                gateway      = "10.0.30.254"
            }
        }
    }
}
