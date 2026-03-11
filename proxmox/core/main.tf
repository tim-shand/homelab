#======================================================#
# Proxmox: Terraform - Main (Root)
#======================================================#

# Cluster Configuration -------------------------------------------------------#
# Import: `terraform import proxmox_virtual_environment_cluster_options.options cluster`
resource "proxmox_virtual_environment_cluster_options" "cluster_options" {
  #description               = "Homelab: Proxmox VE" # Known Bug: ("Homelab: Proxmox VE"), but now cty.StringVal("Homelab: Proxmox VE\n").
  language    = "en"
  keyboard    = "en-us"
  email_from  = "alerts@proxmox.${var.pve_sys_node_domain_dns["domain"]}"
  max_workers = 5
  mac_prefix  = "BC:24:11:" # Change last bit only, first 6 are for Proxmox.
  next_id = {
    lower = 200
    upper = 9999
  }
  console = "html5" # Set default viewer.
}
