# =========================================================================== #
# GitLab CE: Bootstrap Deployment
# Description:
# - Utilises existing VM template from Proxmox bootstrapping process.
# =========================================================================== #

# Download Ubuntu Cloud Image ------------------------------------------- #
# Ubuntu cloud images are in qcow2 format, but stored with .img extension, so can be directly uploaded to Proxmox.
resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"                        # Image file type for importing into Proxmox.
  datastore_id = "local"                         # Use the local datastore for storing the downloaded cloud image.
  node_name    = var.pve_nodes["node1"].hostname # Use the first node in the Proxmox cluster for downloading the cloud image.
  url          = "https://cloud-images.ubuntu.com/${var.ubuntu_dist_name}/current/${var.ubuntu_dist_name}-server-cloudimg-amd64.img"
  file_name    = "ubuntu-server-${var.ubuntu_dist_name}-cloudimg-amd64.img"
}

# Generate random password for the default user ------------------------------------------- #
resource "random_password" "default_pw" {
  length           = 16
  override_special = "_%@"
  special          = true
}

# Proxmox VM: Create from Cloud Image ------------------------------------------- #
resource "proxmox_virtual_environment_vm" "gitlab" {
  name        = "svr-mgt-gitlab-prd"
  description = "Management: GitLab CE Server"
  tags        = ["management", "production"]
  operating_system {
    type = "l26"
  }
  tpm_state {
    version = "v2.0"
  }
  node_name       = var.pve_nodes["node1"].hostname # Use the first node in the Proxmox cluster for creating the VM.
  started         = true                            # VM should be started after creation.
  on_boot         = true                            # Started automatically on Proxmox host boot.
  machine         = "q35"                           # Machine type for the VM, using QEMU machine type for UEFI support.
  bios            = "ovmf"                          # Use OVMF BIOS for UEFI support, required for secure boot.
  keyboard_layout = "en-us"                         # Keyboard layout for the VM, using US English layout.
  cpu {
    type  = "x86-64-v2-AES" # recommended for modern CPUs
    cores = 4               # Number of CPU cores allocated to the VM, using 4 cores for better performance.
  }
  memory {
    dedicated = 8192 # Dedicated memory allocated to the VM in MB.
  }
  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m" # Disk type for EFI disk.
  }
  disk {
    datastore_id = var.datastore_id                            # Use the specified datastore for storing the VM disk.
    file_id      = proxmox_download_file.ubuntu_cloud_image.id # Use the previously downloaded cloud image file.
    interface    = "scsi0"                                     # Use SCSI interface for the VM disk for better performance.
    iothread     = true                                        # Offloads disk traffic to its own dedicated CPU thread to boost system response times.
    discard      = "on"                                        # Passes TRIM/UNMAP commands through so the host can reclaim space deleted inside the guest OS.
    size         = 32
  }
  network_device {
    bridge = var.pve_network.guest.bridge # Use the specified "guest" bridge for the VM network device.
  }
  initialization {
    datastore_id = var.datastore_id # Use the specified datastore for storing the cloud-init configuration.
    interface    = "scsi1"          # Use SATA interface for the cloud-init disk.
    dns {
      domain  = var.vm_networking.domain      # Domain name for the VM, used for DNS resolution.
      servers = var.vm_networking.dns_servers # List of DNS servers for the VM.
    }
    ip_config {
      ipv4 {
        address = var.vm_networking.ipv4.address # IPv4 address for the VM, used for network configuration.
        gateway = var.vm_networking.ipv4.gateway # IPv4 gateway for the VM.
      }
    }
    user_account {
      username = var.default_user
      password = random_password.default_pw.result
    }
  }
}
