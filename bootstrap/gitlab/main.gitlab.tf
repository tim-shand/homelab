# =========================================================================== #
# GitLab CE: Bootstrap Deployment
# Description:
# - Downloads and deploy GitLab container (LXC) on Proxmox cluster.
# =========================================================================== #

# Download Image File ------------------------------------------- #
resource "proxmox_download_file" "image" {
  content_type = "vztmpl" # Use 'iso' or 'import' for VM images, or 'vztmpl' for LXC images.
  datastore_id = "local"
  node_name    = var.pve_connection.hostname
  url          = var.container_image_url
}

# # Authentication -------------------------------------- #
resource "random_password" "container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

# resource "tls_private_key" "container_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# GitLab LXC Container --------------------------------------------------- #
resource "proxmox_virtual_environment_container" "gitlab" {
  description   = "GitLab CE"
  node_name     = var.pve_connection.hostname # Proxmox node to deploy container to.
  vm_id         = var.container_config.vmid # ID number of the workload.
  unprivileged  = true # Whether the container runs as unprivileged on the host.
  startup {
    order      = "1"
  }
  operating_system {
    template_file_id = proxmox_download_file.image.id
    type = var.container_config.os_type
  }
  cpu {
    architecture = var.container_config.cpu.architecture
    cores = var.container_config.cpu.cores
  }
  memory {
    dedicated = var.container_config.memory.dedicated
    swap = var.container_config.memory.swap
  }
  disk {
    datastore_id = var.container_config.disk.datastore_id
    size         = var.container_config.disk.size
  }
  network_interface {
    name = var.container_config.network.name
    bridge = var.container_config.network.bridge
    vlan_id = var.container_config.network.vlan_id
  }
  initialization {
    hostname = var.container_config.hostname
    ip_config {
      ipv4 {
        address = var.container_config.network.ipv4 # Or use "dhcp".
        gateway = var.container_config.network.gateway
      }
    }
    dns {
      domain = var.container_config.network.dns_domain
      servers = var.container_config.network.dns_servers
    }
    user_account {
      keys = [var.ssh_public_key]
      password = random_password.container_password.result
    }
  }
}
