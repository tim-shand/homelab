# ========================================================================================================== #
# Global Variables: Proxmox Cluster Configuration
# Description:
# - Global variable definitions for Proxmox cluster, node configuration, resource pools, and SDN zones etc.
# ========================================================================================================== #

# Proxmox Cluster: Nodes ------------------------------------------- #
pve_nodes = {
    "node1" = {
        hostname    = "proxmox-node-01" # Proxmox host name, used to access and identify host in cluster.
        ip_address  = "10.0.0.1"        # Proxmox host IP address, used for API access.
        production  = true              # True/False: Used for targeting resources to production nodes in the cluster.
    }
    "node2" = {
        hostname    = "proxmox-node-02"
        ip_address  = "10.0.0.2"
        production  = true
    }
    "node3" = {
        hostname    = "proxmox-node-03"
        ip_address  = "10.0.0.3"
        production  = false
    }
}

# Proxmox Cluster: Networking ------------------------------------------- #
pve_network = {
  "cluster" = {     # Network configuration for Proxmox cluster.
    nic         = "nic0" # Network interface used for Proxmox cluster communication and management.
    bridge      = "vmbr0" # Linux bridge used for Proxmox cluster.
  }
  "guest" = {       # Network configuration for guest VMs and containers.
    nic         = "nic1"
    bridge      = "vmbr1"
  }
}
