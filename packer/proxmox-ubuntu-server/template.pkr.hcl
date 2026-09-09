# ========================================================================================================== #
# Packer: Proxmox Template - Ubuntu Server
# Description:
# - Packer configuration to provision Ubuntu Server VM template.
# - URL: https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img
# - Usage: packer build -var-file="packer.pkrvars.hcl" .
# ========================================================================================================== #

packer {
  required_plugins {
    name = {
      version = "~> 1.2.4"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Locals ------------------------------------- #

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
}

# Sources -------------------------------------- #

source "proxmox-iso" "proxmox-ubuntu-server" {
    # Proxmox Config ------------------------------------------------------ #
    node        = "${var.pve_nodes["inf-pve-01-prd"].node_name}"
    proxmox_url = "https://${var.pve_nodes["inf-pve-01-prd"].hostname}:8006/api2/json"
    username    = "${var.pve_api_packer_user}" # Proxmox Authentication: API Username
    token       = "${var.pve_api_packer_token}" # Proxmox Authentication: API Token
    insecure_skip_tls_verify = true # Skip TLS Verification for Proxmox with no certificates.

    boot_command = ["<wait>"]
    boot_wait    = "10s"
    communicator = "ssh" # Packer uses communicators to upload files, execute scripts, and perform actions on the machine being created.
    ssh_username = "${var.default_username}" # Image Username
    ssh_password = "${var.default_password}" # Image Password

    # ISO Image Config ------------------------------------------------------ #
    # DEPRECATED
    # #iso_file         = "local:iso/ubuntu-24.04-live-server-amd64.iso"
    # iso_download_pve = true # Force Proxmox to fetch the iso_url directly.
    # iso_url          = "https://cloud-images.ubuntu.com/${var.distro_name}/current/${var.distro_name}-server-cloudimg-amd64.img"

    boot_iso {
      #iso_file         = "local:iso/ubuntu-24.04-live-server-amd64.iso" # Used for existing local Proxmox ISO.
      iso_download_pve = true # Force Proxmox to fetch the iso_url directly.
      iso_url          = "https://cloud-images.ubuntu.com/${lower(var.distro_name)}/current/${lower(var.distro_name)}-server-cloudimg-amd64.img"
      iso_checksum     = "${var.iso_checksum}"
      iso_storage_pool = "${var.pve_storage}"
    }

    # VM Specs ------------------------------------------------------ #
    vm_id            = var.vm_id
    vm_name          = "ztmp-${lower(var.os_name)}-${lower(var.distro_name)}-${replace(var.distro_version, ".","")}" # ztmp-ubuntu-resolute-2604
    template_description = "Template: ${var.os_name} ${var.distro_name} ${var.distro_version} (Built with Packer: ${local.timestamp})."
    qemu_agent = true # Enable Qemu agent for Proxmox.
    memory = 2048
    cores  = 2
    disks {
        disk_size      = "16G"
        storage_pool   = "${var.pve_storage}"
        type           = "scsi"
    }

    # VM Cloud-Init Settings
    cloud_init              = true
    cloud_init_storage_pool = "${var.pve_storage}"

    # VM Network Settings
    network_adapters {
        model    = "virtio"
        bridge   = "${var.pve_nodes["inf-pve-01-prd"].network.guest.bridge}"
        vlan_tag = "${var.vm_vlan_tag}"
        firewall = "false"
    }
}

build {
  sources = ["source.proxmox-iso.proxmox-ubuntu-server"]
}
