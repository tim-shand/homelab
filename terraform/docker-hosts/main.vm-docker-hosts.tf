# ========================================================================================================= #
# Proxmox: Docker Host VMs
# Description:
# - Deploy Docker VMs using Ubuntu cloud-init template.
# terraform -chdir=./terraform/docker-hosts plan -var-file=../../variables/proxmox-global.tfvars -var-file=../../variables/docker-hosts.tfvars
# ========================================================================================================= #

# Proxmox: Deploy VM (Docker Host) ----------------------------------------------- #

locals {
    # Only deploy Docker hosts that are marked as 'enabled'.
    docker_hosts_enabled_prd = {
        for k,v in var.docker_hosts : k => v
        if v.enabled && v.env_prd # If VM is enabled and 'env_prd' is true.
    }
    docker_hosts_enabled_dev = {
        for k,v in var.docker_hosts : k => v
        if v.enabled && !v.env_prd # If VM is enabled and 'env_prd' is NOT true.
    }
    # Read in the local file containing Ansible user SSH public key.
    ansible_ssh_public_key = file("${path.module}/../../files/ssh_keys/${var.ansible_user}.ssh.pub")
}

module "docker_host_prd" {
    for_each        = local.docker_hosts_enabled_prd # Loop each definition in var.docker_hosts
    source          = "../modules/pve-docker-host"
    hostname        = each.key
    pve_node        = var.pve_nodes[each.value.pve_node].node_name # Use short code to select node.
    template_id     = each.value.template_id
    description     = "Docker Host - Production Node"
    tags            = ["docker-prd","ubuntu"]
    pool_id         = each.value.pool_id
    cpu_cores      = 4
    memory_mb      = 4096
    disk_size_gb   = 32
    disk_datastore = var.disk_datastore_prd
    network_bridge = each.value.network_bridge
    ip_address      = each.value.ip_address
    gateway_address = each.value.gateway_address
    dns_servers     = each.value.dns_servers
    dns_domain      = each.value.dns_domain
    ansible_user           = var.ansible_user # Global variables.
    ansible_ssh_public_key = local.ansible_ssh_public_key # Global variables.
}

module "docker_host_dev" {
    for_each        = local.docker_hosts_enabled_dev # Loop each definition in var.docker_hosts
    source          = "../modules/pve-docker-host"
    hostname        = each.key
    pve_node        = var.pve_nodes[each.value.pve_node].node_name # Use short code to select node.
    template_id     = each.value.template_id
    description     = "Docker Host - Development Node"
    tags            = ["docker-dev","ubuntu"]
    pool_id         = each.value.pool_id
    cpu_cores      = 2
    memory_mb      = 2048
    disk_size_gb   = 16
    disk_datastore = var.disk_datastore_dev
    network_bridge = each.value.network_bridge
    ip_address      = each.value.ip_address
    gateway_address = each.value.gateway_address
    dns_servers     = each.value.dns_servers
    dns_domain      = each.value.dns_domain
    ansible_user           = var.ansible_user # Global variables.
    ansible_ssh_public_key = local.ansible_ssh_public_key # Global variables.
}