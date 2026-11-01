# Variables ----------------------------------------------------- #

pve_auth_api_token = "example@pve!api=12345678-1234-1234-1234-1234567890" # Proxmox API token.
datastore_id     = "pve-zfs-pool" # Proxmox datastore ID for storing VM disks and cloud images.
template_ubuntu_id = "9000" # ID of the template created during Proxmox bootstrap process.

vm_specs = {
  name = "svr-mgt-gitvm-prd"
  description = "Management: Gitea Server"
  tags        = ["management", "production"]
  vm_cores   = 4
  vm_memory  = 2048
}

vm_networking = {
  bridge       = "vmbr1"          # Proxmox bridge for VM networking.
  domain       = "svr.mynetwork.net" # Domain name for the VM, used for DNS resolution.
  dns_servers  = ["10.0.20.254"]
  ipv4_address = "10.0.20.10/24" # IPv4 address for the VM, used for network configuration.
  ipv4_gateway = "10.0.20.254"   # Gateway address for network.
}
