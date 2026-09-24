# ========================================================================================================= #
# Proxmox: VM Templates
# Description:
# - Download VM images files and deploy them to be used as VM templates.
# A download file can be imported using its identifier in the format: 
#   node_name/datastore_id:content_type/file_name, e.g.:
# terraform import proxmox_download_file.ubuntu_iso pve/local:iso/ubuntu-24.04-server.iso
# ========================================================================================================= #

# Proxmox: Download Image, Deploy VM Template --------------------------------- #

# module "vm_template_ubuntu_server" {
#     for_each     = local.pve_nodes_production
#     source       = "../../modules/pve-vm-template"
#     pve_node     = each.value.node_name
#     template_id  = var.vm_templates.ubuntu_server.template_id
#     description  = var.vm_templates.ubuntu_server.description
#     src_img_url  = var.vm_templates.ubuntu_server.src_url
#     dst_img_file = var.vm_templates.ubuntu_server.dst_file
#     datastore_id_img = each.value.storage_img
#     datastore_id_vms = each.value.storage_vms
#     nic_bridge   = each.value.network.guest.bridge
# }

# module "vm_template_fedora_server" {
#     for_each     = local.pve_nodes_production
#     source       = "../../modules/pve-vm-template"
#     pve_node     = each.value.node_name
#     template_id  = var.vm_templates.fedora_server.template_id
#     description  = var.vm_templates.fedora_server.description
#     src_img_url  = var.vm_templates.fedora_server.src_url
#     dst_img_file = var.vm_templates.fedora_server.dst_file
#     datastore_id_img = each.value.storage_img
#     datastore_id_vms = each.value.storage_vms
#     nic_bridge   = each.value.network.guest.bridge
# }
