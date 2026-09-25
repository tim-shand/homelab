# ======================================================== #
# MODULE: Proxmox IAM - Service Account Users
# DESCRIPTION: Create service account users and assign to groups + add API token.
# https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_user
# ======================================================== #

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
}

locals {
  name_prefix = "ztmp" # Used at the beginning of the template name.
  formatted_date = formatdate("YYYY-MM-DD_HH-mm", timestamp())
  template_name = replace(var.dst_img_file, "/\\.[^.]*$/", "")
}

# Download Image File ----------------------------------------------- #
resource "proxmox_download_file" "main" {
  node_name    = var.pve_node
  url          = var.src_img_url
  file_name    = var.dst_img_file
  overwrite    = false # File will be replaced if file size has changed outside of Terraform, or file size reported by URL differs.
  overwrite_unmanaged = true # File with same name exists in datastore, it will be deleted and the new file will be downloaded.
  content_type = "import" # Must be iso or import for VM images or vztmpl for LXC images.
  datastore_id = var.datastore_id_img # Defaults to 'local' if not provided.
}

# Create VM Template ----------------------------------------------- #
resource "proxmox_virtual_environment_vm" "main" {
  node_name = var.pve_node
  vm_id     = var.template_id
  name      = "${local.name_prefix}-${local.template_name}"
  description = "${var.description} (Updated: ${local.formatted_date})"
  tags        = ["template"]
  template = true # Required to create as VM template.
  started  = false
  machine = "q35"
  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }
  cpu {
    cores = 2
  }
  memory {
    dedicated = 1024
  }
  efi_disk {
    datastore_id = var.datastore_id_vms # Defaults to 'local-lvm' if not provided.
    type         = "4m"
  }
  disk {
    datastore_id = var.datastore_id_vms # Defaults to 'local-lvm' if not provided.
    import_from = proxmox_download_file.main.id
    interface = "virtio0"
    iothread = true
    discard  = "on"
    size = 16
  }
  network_device {
    bridge = var.network_bridge
  }
  lifecycle {
    ignore_changes = [description] # Ignore for update as timestamp changes each run.
  }
}