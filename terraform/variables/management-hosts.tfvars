management_hosts = {
  "svr-mgt-utl-01" = {
    enabled         = true
    description     = "Management/Utility Jump Host"
    tags            = ["management","env-prd"]
    pve_node        = "node2" # Short code (map key) used by global variable 'pve_nodes' to map with template IDs.
    pool_id         = "pool-prd-2" # Match with PVE node (1, 2) for load balancing and backup schedules.
    cpu_cores       = 2
    memory_mb       = 2048
    disk_size_gb    = 16
    network_bridge  = "vlan20"
    ip_address      = "10.0.20.10/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    datastore_id    = "pve-zfs-pool" # Target datastore for resources (local-lvm).
    data_disks      = {
      #"scsi1" = 8 # Use interface and GB value per entry. Leave blank for none.
    }
  }
}
