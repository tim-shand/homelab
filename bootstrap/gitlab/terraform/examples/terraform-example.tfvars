# Variables ----------------------------------------------------- #

pve_auth_api_token = "example@pve!api=12345678-1234-1234-1234-1234567890" # Proxmox API token.
# ubuntu_dist_name = "resolute"     # Name of Ubuntu distribution to be used for the cloud image.
datastore_id     = "pve-zfs-pool" # Proxmox datastore ID for storing VM disks and cloud images.
template_ubuntu_id = "9000" # ID of the template created during Proxmox bootstrap process.
vm_networking = {
  bridge      = "vmbr1"         # Proxmox bridge for VM networking.
  domain      = "homelab.local" # Domain name for the VM, used for DNS resolution.
  dns_servers = ["10.0.20.1"]
  ipv4_address = "10.0.20.10/24" # IPv4 address for the VM, used for network configuration.
  ipv4_gateway = "10.0.20.1"  # Gateway address for network.
}
