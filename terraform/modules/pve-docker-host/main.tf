# ================================================================= #
# MODULE: Proxmox - Docker Host
# DESCRIPTION: Create Docker VM from existing template.
# ================================================================= #

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
}

# Create Docker VM ----------------------------------------------- #
resource "proxmox_virtual_environment_vm" "main" {
  node_name       = var.pve_node
  name            = var.hostname
  description     = "[Managed by Terraform] ${var.description}"
  tags            = var.tags
  on_boot         = var.start_on_boot
  started         = var.start_after_creation
  stop_on_destroy = true # Force stop the VM instead of shutting it down when destroying.
  clone {
      vm_id = var.template_id
  }
  agent {
    enabled = true # Requires 'qemu-guest-agent' to be pre-baked into template image.
  }
  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = var.memory_mb
  }
  disk {
    datastore_id = var.disk_datastore # Defaults to 'local-lvm' if not provided.
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size_gb # 32GB
  }
  network_device {
    bridge = var.network_bridge
  }
  initialization {
    datastore_id = var.disk_datastore
    ip_config {
        ipv4 {
            address = var.ip_address
            gateway = var.gateway_address
        }
    }
    dns {
        servers = var.dns_servers
        domain  = var.dns_domain
    }
    user_account {
        username = var.ansible_user
        keys = [
          var.ansible_ssh_public_key
        ]
    }
  }
}
