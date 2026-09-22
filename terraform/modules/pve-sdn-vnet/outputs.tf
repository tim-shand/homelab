output "vnets" {
    description = "Output of all created VNets."
    value = proxmox_sdn_vnet.main
}

output "subnets" {
    description = "Output of all created subnets and parent VNets."
    value =  proxmox_sdn_subnet.main
}
