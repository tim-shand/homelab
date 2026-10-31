# ========================================================================================================= #
# Proxmox: Docker Host VMs
# Description:
# - Deploy Docker VMs using Ubuntu cloud-init template.
# terraform -chdir=./terraform/docker-hosts plan -var-file=../../variables/proxmox-global.tfvars -var-file=../../variables/docker-hosts.tfvars
# Remove local host entry for SSH key: ssh-keygen -R <hostname_or_ip>
# ========================================================================================================= #

# Proxmox: Deploy VM (Docker Host) ----------------------------------------------- #

locals {
    # Only deploy Docker hosts that are marked as 'enabled'.
    docker_hosts_enabled = {
      for k,v in var.docker_hosts : k => v
      if v.enabled # Only add to map if VM is enabled.
    }
    # Read in the local file containing Ansible user SSH public key.
    ansible_ssh_public_key = file("${path.module}/../../files/ssh_keys/${var.ansible_user}.ssh.pub")
}

module "docker_host" {
    for_each        = local.docker_hosts_enabled # Loop each definition in var.docker_hosts
    source          = "../modules/pve-vm-ubuntu"
    hostname        = each.key
    pve_node        = var.pve_nodes[each.value.pve_node] # Pass in PVE node object to module to access all properties.
    description     = "Docker Host - ${each.value.enable_prod ? "Production" : "Development"}"
    tags            = ["docker","env-${each.value.enable_prod ? "prd" : "dev"}"]
    pool_id         = each.value.pool_id
    cpu_cores       = var.docker_host_config[each.value.enable_prod ? "prd" : "dev"].cpu_cores
    memory_mb       = var.docker_host_config[each.value.enable_prod ? "prd" : "dev"].memory_mb
    disk_size_gb    = var.docker_host_config[each.value.enable_prod ? "prd" : "dev"].disk_gb
    disk_datastore  = var.docker_host_config[each.value.enable_prod ? "prd" : "dev"].datastore_id
    data_disks      = var.docker_host_config[each.value.enable_prod ? "prd" : "dev"].data_disks
    network_bridge  = each.value.network_bridge
    ip_address      = each.value.ip_address
    gateway_address = each.value.gateway_address
    dns_servers     = each.value.dns_servers
    dns_domain      = each.value.dns_domain
    ansible_user           = var.ansible_user # Global variables.
    ansible_ssh_public_key = local.ansible_ssh_public_key # Global variables.
}
