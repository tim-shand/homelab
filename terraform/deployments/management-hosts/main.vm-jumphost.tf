# ========================================================================================================= #
# Proxmox: VM - Management/Utility Hosts
# Description:
# - Deploy VMs for general purpose, management, utility and jump host purposes.
# Remove local host entry for SSH key: ssh-keygen -R <hostname_or_ip>
# Usage: terraform -chdir=./terraform/deployments/management-hosts plan -var-file=../../variables/proxmox-global.tfvars
# ========================================================================================================= #

# Proxmox: Deploy VMs ----------------------------------------------- #

locals {
  # Read in the local file containing Ansible user SSH public key.
  ansible_ssh_public_key = file("${path.module}/../../../files/ssh_keys/${var.ansible_user}.ssh.pub")
}

module "vm_jumphost" {
    source          = "../../modules/pve-vm-ubuntu"
    hostname        = "svr-mgt-utl-01"
    pve_node        = var.pve_nodes["node2"]
    description     = "Management/Utility Jump Host"
    tags            = ["management","env-prd"]
    pool_id         = "pool-prd-2"
    cpu_cores       = 2
    memory_mb       = 2048
    disk_size_gb    = 16
    disk_datastore  = var.pve_nodes["node2"].datastore_vms
    data_disks      = {
      #"scsi1" = 8 # Use interface and GB value per entry.
    }
    network_bridge  = "vlan20"
    ip_address     = "10.0.20.10/24"
    gateway_address = "10.0.20.254"
    dns_servers     = ["10.0.20.254"]
    dns_domain      = "svr.tshand.net"
    ansible_user           = var.ansible_user # Global variables.
    ansible_ssh_public_key = local.ansible_ssh_public_key
}
