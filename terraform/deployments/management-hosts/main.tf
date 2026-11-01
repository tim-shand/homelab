# ========================================================================================================= #
# Proxmox: VM - Management/Utility Hosts
# Description:
# - Deploy VMs for general purpose, management, utility and jump host purposes.
# Remove local host entry for SSH key: ssh-keygen -R <hostname_or_ip>
# Usage: terraform -chdir=./terraform/deployments/management-hosts apply \
# -var-file=../../variables/proxmox-global.tfvars -var-file=../../variables/management-hosts.tfvars
# ========================================================================================================= #

locals {
    # Only deploy Docker hosts that are marked as 'enabled'.
    management_hosts_enabled = {
      for k,v in var.management_hosts : k => v
      if v.enabled # Only add to map if VM is enabled.
    }
    # Read in the local file containing Ansible user SSH public key.
    ansible_ssh_public_key = file("${path.module}/../../../files/ssh_keys/${var.ansible_user}.ssh.pub")
}

module "vm_management" {
    for_each        = local.management_hosts_enabled # Loop each definition in var.docker_hosts
    source          = "../../modules/pve-vm-ubuntu"
    hostname        = each.key
    pve_node        = var.pve_nodes[each.value.pve_node] # Pass in PVE node object to module to access all properties.
    description     = each.value.description
    tags            = each.value.tags
    pool_id         = each.value.pool_id
    cpu_cores       = each.value.cpu_cores
    memory_mb       = each.value.memory_mb
    disk_size_gb    = each.value.disk_size_gb
    disk_datastore  = each.value.datastore_id
    data_disks      = each.value.data_disks
    network_bridge  = each.value.network_bridge
    ip_address      = each.value.ip_address
    gateway_address = each.value.gateway_address
    dns_servers     = each.value.dns_servers
    dns_domain      = each.value.dns_domain
    ansible_user           = var.ansible_user # Global variables.
    ansible_ssh_public_key = local.ansible_ssh_public_key # Global variables.
}
