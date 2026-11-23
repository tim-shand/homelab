# ========================================================================================================= #
# Proxmox: SDN (Software Defined Networking)
# Description:
# - Configuration for defining Proxmox SDN (Software Defined Networking) components.
# - Network definitions for Proxmox cluster and VM traffic, using separate bridges and VLANs for isolation.
# - Proxmox SDN Hierarchy: Zone --> VNet --> Subnet
# ========================================================================================================= #

# SDN: VNets --------------------------------------------------------- #
# Deploy VNets, VLANs and subnets using custom module.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/sdn_applier

module "pve_sdn_vnet" {
  source        = "../../modules/pve-sdn-vnet"
  for_each      = var.pve_sdn_vnets               # Loop each defined VNet and it's subnets from variables.
  zone_id       = each.value.zone_id
  vnet_id       = each.key                        # Use looped key value for name.
  vlan_tag      = each.value.vlan_tag             # VLAN tag for VNet, used for traffic isolation and segmentation.
  isolate_ports = each.value.isolate_ports        # True/False: Guests can only send traffic to non-isolated bridge-ports (the bridge itself).
  vlan_aware    = each.value.vlan_aware           # Disable for VNet level tagging. Enables vlan-aware on interface, requiring configuration in the guest.
  subnets       = each.value.subnets              # Map of subnets to create in the VNet.
  depends_on = [
    proxmox_sdn_applier.init, # Runs first, applies any pre-existing pending state (manual, interrupted, failed).
    proxmox_sdn_zone_simple.main,
    proxmox_sdn_zone_vlan.main
  ]
}
