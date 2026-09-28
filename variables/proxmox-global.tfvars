# =============================================================== #
# VARIABLES: Proxmox - Global Definitions
# =============================================================== #

# Proxmox: Networking Configuration
pve_network = {
    bridge_cluster = "vmbr0"
    bridge_guest   = "vmbr1"
}

# Proxmox: Node Configuration
pve_nodes = {
    "node1" =  {
        node_name = "inf-hvr-pve-01"
        description = "Proxmox Node 1: Managed by Terraform | Storage=Local,ZFS | Dual NIC"
        ip_address = "10.0.10.1"
        datastore_img = "local" # Storage location for VM templates.
        datastore_vms = "pve-zfs-pool" # Storage location for VMs and containers.
    }
    "node2" =  {
        node_name = "inf-hvr-pve-02"
        description = "Proxmox Node 2: Managed by Terraform | Storage=Local,ZFS | Dual NIC"
        ip_address = "10.0.10.2"
        datastore_img = "local" # Storage location for VM templates.
        datastore_vms = "pve-zfs-pool" # Storage location for VMs and containers.
    }
    "node3" =  {
        node_name = "inf-hvr-pve-03"
        description = "Proxmox Node 3: Managed by Terraform | Storage=Local | Single NIC"
        ip_address = "10.0.10.3"
        datastore_img = "local" # Storage location for VM templates.
        datastore_vms = "local-lvm" # Storage location for VMs and containers.
    }
}
