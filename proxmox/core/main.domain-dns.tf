# Node Domain & DNS ------------------------------------------------------------#
# Import: `terraform import proxmox_virtual_environment_dns.first_node first-node`
resource "proxmox_virtual_environment_dns" "pve_sys_dns_01" {
  node_name = var.pve_host_config_01["name"]        # Node Name
  domain    = var.pve_sys_node_domain_dns["domain"] # Domain
  servers = [
    var.pve_sys_node_domain_dns["dns1"], # Primary DNS
    var.pve_sys_node_domain_dns["dns2"]  # Secondary DNS
  ]
}

resource "proxmox_virtual_environment_dns" "pve_sys_dns_02" {
  node_name = var.pve_host_config_02["name"]        # Node Name
  domain    = var.pve_sys_node_domain_dns["domain"] # Domain
  servers = [
    var.pve_sys_node_domain_dns["dns1"], # Primary DNS
    var.pve_sys_node_domain_dns["dns2"]  # Secondary DNS
  ]
}
