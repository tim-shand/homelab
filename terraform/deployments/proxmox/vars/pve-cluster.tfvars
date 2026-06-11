# Variables: Cluster Configuration ------------------------------------------- #

pve_nodes = {
  "node1" = {
    hostname    = "inf-pve-01-prd" # Proxmox host name, used to access and identify host in cluster.
    dns_domain  = "mgt.tshand.net" # Proxmox host domain, used to compile full FQDN host name.
    ip_address  = "10.0.10.1" # Proxmox host IP address, used for API access.
    production = true # Used for targeting resources to production nodes in the cluster.
    network = {
      pve = {
        nic_name    = "nic0" # Network interface used for Proxmox cluster communication and management.
        bridge_name = "vmbr0" # Bridge used for Proxmox cluster, should be on separate VLAN from VM traffic.
      }
      vms = {
        nic_name    = "nic1" # Network interface used for VM traffic, should be on separate VLAN from Proxmox management network.
        bridge_name = "vmbr1" # Bridge used for VM traffic, should be on separate VLAN from Proxmox management network.
      }
    }
  }
  "node2" = {
    hostname    = "inf-pve-02-prd"
    dns_domain  = "mgt.tshand.net"
    ip_address  = "10.0.10.2"
    production = true # Used for targeting resources to production nodes in the cluster.
    network = {
      pve = {
        nic_name    = "nic0"
        bridge_name = "vmbr0"
      }
      vms = {
        nic_name    = "nic1"
        bridge_name = "vmbr1"
      }
    }
  }
  "node3" = {
    hostname    = "inf-pve-03-dev"
    dns_domain  = "mgt.tshand.net"
    ip_address  = "10.0.10.3"
    production = true # Used for targeting resources to production nodes in the cluster.
    network = {
      pve = {
        nic_name    = "nic0"
        bridge_name = "vmbr0"
      }
      vms = {
        nic_name    = "nic0"  # Same as Proxmox management network on this host, as it is used for development and testing.
        bridge_name = "vmbr0" # Same as Proxmox management network on this host, as it is used for development and testing.
      }
    }
  }
}

# Proxmox Virtual Environment Pools ------------------------------------------- #
pve_pools = {
  "prd" = {
    pool_id = "production-pool"
    comment = "Production Workloads"
  }
  "dev" = {
    pool_id = "development-pool"
    comment = "Development Workloads"
  }
}

# Proxmox SDN: Zones ------------------------------------------- #

# pve_sdn_zones = {
#   "vlan_zone" = {
#     id      = "ZoneVLAN"
#     bridge  = "vmbr1"
#     mtu     = 1500
#     # nodes = [
#     #   var.pve_nodes.node1.hostname,
#     #   var.pve_nodes.node2.hostname,
#     # ]
#     # Optional Attributes. Only required if using Proxmox IPAM for DHCP and DNS management.
#     # Ignore for OPNsense DHCP and DNS management.
#     # dns         = "1.1.1.1"
#     # dns_zone    = "example.com"
#     # ipam        = "pve"
#     # reverse_dns = "1.1.1.1"
#   }
# }
