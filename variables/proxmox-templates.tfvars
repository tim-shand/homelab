# =============================================================== #
# VARIABLES: Proxmox - VM Templates
# =============================================================== #

vm_templates = {
    ubuntu_server = {
        template_name = "ztmp-ubuntu-server-resolute-2604-cloudinit"
        description = "[Managed by Terraform] VM Template - Ubuntu Server"
        enabled = true
        src_url = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
        dst_file = "ubuntu-server-26-04-resolute-cloudimg.qcow2"
        template_disk_size = 16 # Resize VM template disk.
        network_bridge = "vlan20"
        vm_ids = {
            node1 = 910
            #node2 = 911
            #node3 = 912
        }
    }
    fedora_server = {
        template_name = "ztmp-fedora-server-44-1-7-cloudinit"
        description = "[Managed by Terraform] VM Template - Fedora Server"
        enabled = false
        src_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/44/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2"
        dst_file = "fedora-server-44-1-7-cloudimg.img"
        template_disk_size = 16 # Resize VM template disk.
        network_bridge = "vlan20"
        vm_ids = {
            node1 = 910
            node2 = 911
            #node3 = 912
        }
    }
}
