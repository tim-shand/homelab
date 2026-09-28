docker_hosts = {
  "svr-dkr-dev-01" = {
    enabled        = true
    pve_node       = "node1"
    pool_id        = "pool-dev"
    cpu_cores      = 4
    memory         = 4096
    disk_size      = 32
    disk_datastore = "pve-zfs-pool"
    network_bridge = "vlan20"
    ip_address     = "10.0.20.30/24"
    gateway_address = "10.0.20.254"
    dns_domain      = "svr.tshand.net"
  }
  "svr-dkr-dev-02" = {
    enabled        = false
    pve_node       = "node2"
    pool_id        = "pool-dev"
    cpu_cores      = 4
    memory         = 4096
    disk_size      = 32
    disk_datastore = "pve-zfs-pool"
    network_bridge = "vlan20"
    ip_address     = "10.0.20.31/24"
    gateway_address = "10.0.20.254"
    dns_domain      = "svr.tshand.net"
  }
  "svr-dkr-prd-01" = {
    enabled        = false
    pve_node       = "node1"
    pool_id        = "pool-prd-1"
    cpu_cores      = 4
    memory         = 4096
    disk_size      = 32
    disk_datastore = "pve-zfs-pool"
    network_bridge = "vlan20"
    ip_address     = "10.0.20.20/24"
    gateway_address = "10.0.20.254"
    dns_domain      = "svr.tshand.net"
  }
  "svr-dkr-prd-02" = {
    enabled        = false
    pve_node       = "node2"
    pool_id        = "pool-prd-2"
    cpu_cores      = 4
    memory         = 4096
    disk_size      = 32
    disk_datastore = "pve-zfs-pool"
    network_bridge = "vlan20"
    ip_address     = "10.0.20.21/24"
    gateway_address = "10.0.20.254"
    dns_domain      = "svr.tshand.net"
  }
}
