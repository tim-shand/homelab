# ========================================================================================================= #
# Proxmox: VM Templates
# Description:
# - Download VM images files and deploy them to be used as VM templates.
# A download file can be imported using its identifier in the format: 
#   node_name/datastore_id:content_type/file_name, e.g.:
# terraform import proxmox_download_file.ubuntu_iso pve/local:iso/ubuntu-24.04-server.iso
# ========================================================================================================= #

# Proxmox: Download Image, Deploy VM Template --------------------------------- #

module "vm_template_ubuntu_server" {
    # Only deploy if templated is enabled, and to nodes listed within variable 'vm_ids'.
    for_each     = var.vm_templates.ubuntu_server.enabled ? var.vm_templates.ubuntu_server.vm_ids : {}
    source       = "../../modules/pve-vm-template"
    pve_node     = var.pve_nodes[each.key].node_name # Map node name from global 'pve_nodes' variable to 'vm_ids' map.
    template_id  = each.value # Use loop from template 'vm_ids' map.
    description  = var.vm_templates.ubuntu_server.description
    src_img_url  = var.vm_templates.ubuntu_server.src_url
    dst_img_file = var.vm_templates.ubuntu_server.dst_file
    datastore_id_img = var.pve_nodes[each.key].storage_img
    datastore_id_vms = var.pve_nodes[each.key].storage_vms
    network_bridge   = var.vm_templates.ubuntu_server.network_bridge
}

module "vm_template_fedora_server" {
    # Only deploy if templated is enabled, and to nodes listed within variable 'vm_ids'.
    for_each     = var.vm_templates.fedora_server.enabled ? var.vm_templates.fedora_server.vm_ids : {}
    source       = "../../modules/pve-vm-template"
    pve_node     = var.pve_nodes[each.key].node_name # Map node name from global 'pve_nodes' variable to 'vm_ids' map.
    template_id  = each.value # Use loop from template 'vm_ids' map.
    description  = var.vm_templates.fedora_server.description
    src_img_url  = var.vm_templates.fedora_server.src_url
    dst_img_file = var.vm_templates.fedora_server.dst_file
    datastore_id_img = var.pve_nodes[each.key].storage_img
    datastore_id_vms = var.pve_nodes[each.key].storage_vms
    network_bridge   = var.vm_templates.fedora_server.network_bridge
}
