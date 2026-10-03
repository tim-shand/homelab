# =============================================================== #
# VARIABLES: Proxmox - VM Templates
# =============================================================== #

vm_templates = {
    ubuntu_server = {
        template_name = "ztmp-ubuntu-server-resolute-2604-cloudinit"
        description = "[Managed by Terraform] VM Template - Ubuntu Server"
        enabled = false # Toggle 'false' --> 'true' in order to rebuild template.
        src_url = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
        dst_file = "ubuntu-server-26-04-resolute-cloudimg.qcow2"
        template_disk_size = 16 # Resize VM template disk.
        network_bridge = "vlan20"
        vm_ids = {
            node1 = 9010
            #node2 = 9011
            #node3 = 9012
        }
    }
    fedora_server = {
        template_name = "ztmp-fedora-server-44-1-7-cloudinit"
        description = "[Managed by Terraform] VM Template - Fedora Server"
        enabled = false
        src_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/44/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2"
        dst_file = "fedora-server-44-1-7-cloudimg.qcow2"
        template_disk_size = 16 # Resize VM template disk.
        network_bridge = "vlan20"
        vm_ids = {
            #node1 = 9020
            #node2 = 9021
            #node3 = 9122
        }
    }
}
