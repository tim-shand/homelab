disk_datastore_prd = "pve-zfs-pool" # local-lvm
disk_datastore_dev = "pve-zfs-pool" # local-lvm

docker_hosts = {
  "svr-dkr-prd-01" = {
    enabled        = true
    env_prd        = true
    pve_node       = "node1" # Short code used by global variable 'pve_nodes'.
    template_id    = 9010 # Template ID must match template ID on specific target PVE node.
    pool_id        = "pool-prd-1"
    ip_address     = "10.0.20.20/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
  "svr-dkr-prd-02" = {
    enabled        = true
    env_prd        = true
    pve_node       = "node2" # Short code used by global variable 'pve_nodes'.
    template_id    = 9011 # Template ID must match template ID on specific target PVE node.
    pool_id        = "pool-prd-2"
    ip_address     = "10.0.20.21/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
  "svr-dkr-dev-01" = {
    enabled        = true
    env_prd        = false
    pve_node       = "node1" # Short code used by global variable 'pve_nodes'.
    template_id    = 9010 # Template ID must match template ID on specific target PVE node.
    pool_id        = "pool-dev"
    ip_address     = "10.0.20.30/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
  "svr-dkr-dev-02" = {
    enabled        = true
    env_prd        = false
    pve_node       = "node2" # Short code used by global variable 'pve_nodes'.
    template_id    = 9011 # Template ID must match template ID on specific target PVE node.
    pool_id        = "pool-dev"
    ip_address     = "10.0.20.31/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    network_bridge = "vlan20"
  }
}
