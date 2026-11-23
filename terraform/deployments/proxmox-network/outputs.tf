output "pve_network_bridges" {
    description = "List hardcoded Proxmox bridge names."
    value = var.pve_network_bridges
}

output "pve_sdn_vnets" {
    description = "List of all Proxmox SDN network vnets, vlans, and subnets."
    value = module.pve_sdn_vnet
}
