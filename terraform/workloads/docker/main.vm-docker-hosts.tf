# ========================================================================================================= #
# Proxmox: Docker Host VMs
# Description:
# - Deploy Docker VMs using Ubuntu cloud-init template.
# ========================================================================================================= #

# Proxmox: Deploy VM (Docker Host) ----------------------------------------------- #

locals {
    # Only deploy Docker hosts that are marked as 'enabled'.
    docker_hosts_enabled = {
        for k,v in var.docker_hosts : k => v
        if v.enabled # If value = TRUE
    }
}

module "docker_host" {
    for_each        = local.docker_hosts_enabled # Loop each definition in var.docker_hosts
    source          = "../../modules/pve-docker-host"
    hostname        = each.key
    pve_node        = var.pve_nodes[each.value.pve_node].node_name # Use short code to select node.
    template_id     = var.template_id
    #description     = "" # Use default value.
    pool_id         = each.value.pool_id
    ip_address      = each.value.ip_address
    gateway_address = each.value.gateway_address
    dns_servers     = each.value.dns_servers
    dns_domain      = each.value.dns_domain
    ansible_user           = var.ansible_user # Global variables.
    ansible_ssh_public_key = var.ansible_ssh_public_key # Global variables.
}
