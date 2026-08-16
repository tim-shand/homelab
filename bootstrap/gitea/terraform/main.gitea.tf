# =========================================================================== #
# Gitea: Bootstrap Deployment
# Description:
# - Creates new VM from cloning template from Proxmox bootstrapping process.
# =========================================================================== #

# # Generate PEM and OpenSSH formatted private key ------------------------------------------- #
# # Access the keys using `tls_private_key.this.public_key_openssh` or `tls_private_key.this.public_key_pem`
# # https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
# resource "tls_private_key" "gitvm" {
#   algorithm = "ED25519"
#   rsa_bits  = 2048
# }

# # Export SSH Keys ------------------------------------------- #
# # Export the Private Key to a local file.
# resource "local_sensitive_file" "gitvm_private_key" {
#   content         = tls_private_key.gitvm.private_key_openssh
#   filename        = "${path.module}/../ssh_keys/gitvm-ssh"
#   file_permission = "0600"
# }

# # Export the Public Key to a local file.
# resource "local_file" "gitvm_public_key" {
#   content         = tls_private_key.gitvm.public_key_openssh
#   filename        = "${path.module}/../ssh_keys/gitvm-ssh.pub"
#   file_permission = "0644"
# }

# Generate random password for the default user ------------------------------------------- #
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "gitvm" {
  length           = 16
  override_special = "_@!-" # Supply list of special characters to use for string generation.
  special          = true   # Special argument must be set to true for overwritten characters to be used.
}

# Proxmox VM: Create from Cloud Image ------------------------------------------- #
resource "proxmox_virtual_environment_vm" "gitvm" {
  clone {
    vm_id = var.template_ubuntu_id # ID number of the Ubuntu cloud image template created during Proxmox bootstrap.
    full  = true                   # Full clone, not linked to template as a base image.
  }
  name        = var.vm_specs.name
  description = var.vm_specs.description
  tags        = var.vm_specs.tags
  operating_system {
    type = "l26"
  }
  tpm_state {
    datastore_id = var.datastore_id
    version      = "v2.0"
  }
  node_name       = var.pve_nodes["node1"].hostname # Use the first node in the Proxmox cluster for creating the VM.
  started         = true                            # VM should be started after creation.
  on_boot         = true                            # Started automatically on Proxmox host boot.
  machine         = "q35"                           # Machine type for the VM, using QEMU machine type for UEFI support.
  bios            = "ovmf"                          # Use OVMF BIOS for UEFI support, required for secure boot.
  keyboard_layout = "en-us"                         # Keyboard layout for the VM, using US English layout.
  cpu {
    type  = "x86-64-v2-AES"       # Recommended for modern CPUs.
    cores = var.vm_specs.vm_cores # Number of CPU cores allocated to the VM, using 4 cores for better performance.
  }
  memory {
    dedicated = var.vm_specs.vm_memory # Dedicated memory allocated to the VM in MB.
  }
  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m" # Disk type for EFI disk.
  }
  disk {
    datastore_id = var.datastore_id # Use the specified datastore for storing the VM disk.
    interface    = "scsi0"          # Use SCSI interface for the VM disk for better performance.
    discard      = "on"             # Passes TRIM/UNMAP commands through so the host can reclaim space deleted inside the guest OS.
    size         = 32
  }
  network_device {
    bridge  = var.pve_network.guest.bridge # Get from global variables. Use the specified "guest" bridge for the VM network device.
    vlan_id = "20"                         # VLAN ID for the VM network device, used for network segmentation. No SDN configured yet.
  }
  # Cloud-init Configuration
  # https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/cloud-init
  initialization {
    upgrade      = false            # Disable auto-update for packages on first boot. This can lock up Apt and prevent Ansible installing gitea.
    datastore_id = var.datastore_id # Use the specified datastore for storing the cloud-init configuration.
    ip_config {
      ipv4 {
        address = var.vm_networking.ipv4_address # IPv4 address for the VM, used for network configuration.
        gateway = var.vm_networking.ipv4_gateway # IPv4 gateway for the VM.
      }
    }
    dns {
      domain  = var.vm_networking.domain      # Domain name for the VM, used for DNS resolution.
      servers = var.vm_networking.dns_servers # List of DNS servers for the VM.
    }
    user_account {
      username = var.default_user
      password = random_password.gitvm.result
      keys     = [trimspace(file("${var.ssh_key_path}/${var.default_user}.ssh.pub"))]
    }
  }
}
