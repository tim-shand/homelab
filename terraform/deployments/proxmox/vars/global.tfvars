# ========================================================================================================== #
# Global Variables: Proxmox Cluster Configuration
# Description:
# - Global variable definitions for Proxmox cluster, node configuration, resource pools, and SDN zones etc.
# ========================================================================================================== #

global = {
    network = {
        mtu = 1500 # Default MTU for Proxmox cluster and SDN zones, can be overridden in specific SDN zone configurations if needed.
        pve = {         # Network configuration for Proxmox cluster.
            nic         = "nic0" # Network interface used for Proxmox cluster communication and management.
            bridge      = "vmbr0" # Linux bridge used for Proxmox cluster.
        }
        guest = {       # Network configuration for guest VMs and containers.
            nic         = "nic1"
            bridge      = "vmbr1"
        }
    }
    pve_nodes = {
        "node1" = {
            hostname    = "inf-pve-01-prd"  # Proxmox host name, used to access and identify host in cluster.
            ip_address  = "10.0.10.1"       # Proxmox host IP address, used for API access.
            production  = true              # True/False: Used for targeting resources to production nodes in the cluster.
        }
        "node2" = {
            hostname    = "inf-pve-02-prd"
            ip_address  = "10.0.10.2"
            production  = true
        }
        "node3" = {
            hostname    = "inf-pve-03-prd"
            ip_address  = "10.0.10.3"
            production  = false
        }
    }
}
