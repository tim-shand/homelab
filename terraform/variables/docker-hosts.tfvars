docker_host_config = {
  "prd" = {
    cpu_cores    = 4              # Number of CPU cores assigned.
    memory_mb    = 4096           # Memory assigned to VM in MB.
    disk_gb      = 16             # Size of primary disk in GB.
    datastore_id = "pve-zfs-pool" # Target datastore for resources (local-lvm).
    data_disks = {
      "scsi1" = 8 # Use interface and GB value per entry.
    }
  }
  "dev" = {
    cpu_cores    = 2              # Number of CPU cores assigned.
    memory_mb    = 2048           # Memory assigned to VM in MB.
    disk_gb      = 16             # Size of primary disk in GB.
    datastore_id = "pve-zfs-pool" # Target datastore for resources (local-lvm).
    data_disks = {
      "scsi1" = 8 # Use interface and GB value per entry.
    }
  }
}

docker_hosts = {
  # Docker: Production Hosts -------------------------------- #
  "svr-dkr-prd-01" = {
    enabled        = true
    enable_prod    = true # True/False - Enable to mark as production host.
    pve_node       = "node1" # Short code (map key) used by global variable 'pve_nodes' to map with template IDs.
    pool_id        = "pool-prd-1"
    ip_address     = "10.0.20.20/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
  "svr-dkr-prd-02" = {
    enabled        = false
    enable_prod    = true # True/False - Enable to mark as production host.
    pve_node       = "node2"
    pool_id        = "pool-prd-2"
    ip_address     = "10.0.20.21/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
  # Docker: Development Hosts -------------------------------- #
  "svr-dkr-dev-01" = {
    enabled        = false
    enable_prod    = false # True/False - Enable to mark as production host.
    pve_node       = "node1" # Short code (map key) used by global variable 'pve_nodes'.
    pool_id        = "pool-dev"
    ip_address     = "10.0.20.22/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
  "svr-dkr-dev-02" = {
    enabled        = false
    enable_prod    = false # True/False - Enable to mark as production host.
    pve_node       = "node2"
    pool_id        = "pool-dev"
    ip_address     = "10.0.20.23/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
}
