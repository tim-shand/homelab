# ======================================================== #
# MODULE: Proxmox Software-Defined Networking - VLAN
# DESCRIPTION: Create VNet and subnet in Proxmox SDN.
# ======================================================== #

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
}

# Proxmox: VNet --------------------------------- #
resource "proxmox_sdn_vnet" "main" {
  id            = var.vnet_id       # Max 8 characters, no symbols.
  zone          = var.zone_id       # Zone ID from above.
  alias         = var.vnet_id       # VNet alias, used for identification and management in Proxmox UI.
  tag           = var.vlan_tag      # VLAN tag for VNet, used for traffic isolation and segmentation.
  isolate_ports = var.isolate_ports # True/False: Guests can only send traffic to non-isolated bridge-ports (the bridge itself).
  vlan_aware    = var.vlan_aware    # Disable for VNet level tagging. Enables vlan-aware on interface, requiring configuration in the guest. 
}

# Proxmox: Subnet --------------------------------- #
resource "proxmox_sdn_subnet" "main" {
  for_each   = var.subnets
  vnet       = var.vnet_id             # VNet ID for target/parent VNet.
  cidr       = each.value.cidr_address # Subnet IP range.
  gateway    = each.value.gateway      # Network gateway address.
  depends_on = [proxmox_sdn_vnet.main] # Requires VNet to exist first.
}
