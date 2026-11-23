# # ========================================================================================================= #
# # Proxmox: VM Templates
# # Description:
# # - Download cloud-init VM images and deploy them as VM templates in Proxmox.
# # - NOTE: Requires both the Sys.Audit and Sys.Modify privileges.
# # ========================================================================================================= #

# # Proxmox: Download Image File ------------------------------------------------------- #
# # https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/download_file

# locals {
#     image_vmid_base = 8000
#     image_distro_name = "Ubuntu"
#     image_version_number = "2604"
#     image_version_name = "Resolute"
#     image_pinned_build = "20261108"
#     image_url_prefix = "https://cloud-images.ubuntu.com"
#     image_filename = "resolute-server-cloudimg-amd64.img"
#     image_checksum = "7b90593f5532b49b7e3fe3d2743f0d1f0d822e5b07cebcd8e00c0df8069ecab9"
#     datastore_id_images   = "local"
#     datastore_id_snippets = "local"
#     datastore_id_disks    = "local-lvm"
#     vm_hostname_prefix = "ztmp-ubuntu-server"
# }

# # Random Number ------------------------------------------------------- #
# # Used to suffix the VM template host names.
# resource "random_integer" "vm_suffix" {
#   min = 1000
#   max = 9999
# }

# # Snippet ------------------------------------------------------- #
# # Create Cloud-init file to configure system post-deployment.
# # Snippets are not enabled by default in new Proxmox installations. 
# # You need to enable them in the 'Datacenter>Storage' section of the proxmox interface before first using this resource.
# resource "proxmox_virtual_environment_file" "config_ubuntu" {
#   for_each      = toset(data.proxmox_virtual_environment_nodes.pve_nodes.names) # Create on each node.
#   node_name     = each.value # Use result from data to target each PVE node.
#   content_type  = "snippets"
#   datastore_id  = local.datastore_id_snippets
#   file_name = "ztmp-vm-${lower(local.image_distro_name)}-cloud-config.yaml"
#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     hostname: ${local.vm_hostname_prefix}-${random_integer.vm_suffix.result}
#     packages:
#       - qemu-guest-agent
#     users:
#       - name: ${var.default_user.username}
#         groups: [sudo]
#         shell: /bin/bash
#         sudo: ALL=(ALL:ALL) ALL
#         lock_passwd: false
#       - name: svc-ansible
#         groups: [sudo]
#         shell: /bin/bash
#         sudo: ALL=(ALL) NOPASSWD:ALL
#         lock_passwd: true
#         ssh-authorized-keys:
#           - ${trimspace(tls_private_key.example.public_key_openssh)}
#     chpasswd:
#       expire: false # Prevents forcing a password reset on first login
#       list: |
#         ${var.default_user.username}:${var.default_user.password}
#     runcmd:
#       - systemctl enable qemu-guest-agent
#       - systemctl start qemu-guest-agent
#     EOF    
#   }
# }

# # Image File ------------------------------------------------------- #
# # Download to each target PVE node.

# resource "proxmox_download_file" "img_ubuntu" {
#   for_each           = toset(data.proxmox_virtual_environment_nodes.pve_nodes.names) # Create on each node.
#   node_name          = each.value # Use result from data to target each PVE node.
#   datastore_id       = local.datastore_id_images
#   content_type       = "iso" # The file content type. Must be iso or import for VM images or vztmpl for LXC images.
#   url                = lower("${local.image_url_prefix}/${local.image_version_name}/${local.image_pinned_build}/${local.image_filename}")
#   file_name          = lower("${local.image_distro_name}-${local.image_version_number}-${local.image_version_name}.img")
#   checksum           = local.image_checksum # The expected checksum of the file.
#   checksum_algorithm = "sha256" # The algorithm to calculate the checksum of the file. Must be md5 | sha1 | sha224 | sha256 | sha384 | sha512.
#   overwrite          = true # File will be replaced if file size has changed outside of Terraform, or file size reported by the URL differs.
# }

# # Proxmox VM: Template ------------------------------------------------------- #
# # Deploy VM template to each target PVE node.

# resource "proxmox_virtual_environment_vm" "vm_template_ubuntu" {
#   for_each        = toset(data.proxmox_virtual_environment_nodes.pve_nodes.names) # Create on each node.
#   node_name       = each.value # Use result from data to target each PVE node.
#   name            = "zmtp"
#   description     = "[Managed by Terraform] ${local.image_distro_name} ${local.image_version_number} ${local.image_version_name} (${local.image_pinned_build})"
#   tags            = ["template"]
#   template        = true # Setting this from false to true converts an existing VM to a template in place.
#   stop_on_destroy = true # Force stop the VM instead of shutting it down when destroying.
#   purge_on_destroy = true # Whether to purge the VM from backup configurations on destroy.
#   machine         = "q35"  # Machine type for the VM, using QEMU machine type for UEFI support.
#   bios            = "ovmf" # Use OVMF BIOS for UEFI support, required for secure boot (seabios = old BIOS).
#   agent {
#     enabled = true # Requires 'qemu-guest-agent' to be pre-baked into template image.
#   }
#   operating_system {
#     type = "l26"
#   }
#   tpm_state {
#     datastore_id = local.datastore_id_disks
#     version      = "v2.0"
#   }
#   cpu {
#     type  = "x86-64-v2-AES" # Most compatible across different PVE nodes.
#   }
#   memory {
#     dedicated = 1024 # Dedicated memory in MB.
#   }
#   network_device {
#     bridge = var.network_bridge
#   }
#   efi_disk {
#     datastore_id = local.datastore_id_disks
#     type         = "4m" # Disk type for EFI disk.
#   }
#   disk {
#     datastore_id = local.datastore_id_disks # Defaults to 'local-lvm' if not provided.
#     interface    = "scsi0"
#     size         = 16
#   }
#   initialization {
#     datastore_id            = local.datastore_id_disks
#     vendor_data_file_id     = proxmox_virtual_environment_file.config_ubuntu.id
#   }
# }