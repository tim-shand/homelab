# ========================================================================================================== #
# Packer: Proxmox Template - Ubuntu Server
# Description:
# - Packer configuration to provision Ubuntu Server VM template.
# ========================================================================================================== #

# Variables -------------------------------------- #

variable "pve_api_user" {
  type    = string
}

variable "pve_api_token" {
  type    = string
}

variable "os_version" {
    type = string
    default = "24.04"
}

variable "password" {
  type    = string
  default = "supersecret"
}

# Sources -------------------------------------- #

source "proxmox-iso" "proxmox-ubuntu-server" {
  # Proxmox Config
  proxmox_url = "https://${var.pve_nodes["node1"].ip_address}:8006/api2/json"
  insecure_skip_tls_verify = true # Skip TLS Verification
  username    = "${var.pve_username}"
  token       = "${var.pve_username}"
  node        = "${var.pve_nodes["node1"]}"
  
  boot_command = ["<wait>"]
  boot_wait    = "10s"
  communicator = "ssh"
  ssh_username = "ubuntu" # Image Username
  ssh_password = "password" # Image Password

  iso_file         = "local:iso/ubuntu-24.04-live-server-amd64.iso"
  vm_id            = 999
  vm_name          = "ubuntu-template"
  template_description = "Ubuntu template built with Packer"

  memory = 2048
  cores  = 2
  disks {
    disk_size      = "32G"
    storage        = "local-lvm"
    type           = "scsi"
  }
}


build {
  sources = ["source.proxmox-iso.proxmox-ubuntu-server"]
}
