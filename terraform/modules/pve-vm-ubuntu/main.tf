# ================================================================= #
# MODULE: Proxmox VM (Ubuntu)
# DESCRIPTION: Create VM from existing Ubuntu VM template.
# ================================================================= #

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.112.0"
    }
  }
}

# Map nodes to specific base/template VM IDs. Select VM ID based on the node targeted.
locals  {
  node_template_map = {
    pve1 = 9010 # Ubuntu Cloud-Init template ID on PVE node 1.
    pve2 = 9011 # Ubuntu Cloud-Init template ID on PVE node 2.
    pve3 = 9012 # Ubuntu Cloud-Init template ID on PVE node 3.
  }
  tags = concat(["os-ubuntu"],var.tags)
}

# Create VM ----------------------------------------------- #
resource "proxmox_virtual_environment_vm" "main" {
  node_name       = var.pve_node.node_name # Get PVE node name from object passed in.
  name            = var.hostname
  description     = "[Managed by Terraform] ${var.description}"
  tags            = local.tags # Merged module tags with tags passed in.
  on_boot         = var.start_on_boot
  started         = var.start_after_creation
  stop_on_destroy = true # Force stop the VM instead of shutting it down when destroying.
  clone {
      full  = true
      vm_id = local.node_template_map[var.pve_node.node_id] # Get template ID based on mapping on PVE node. #var.template_id
  }
  agent {
    enabled = true # Requires 'qemu-guest-agent' to be pre-baked into template image.
  }
  network_device {
    bridge = var.network_bridge
  }
  # Compute ----------------------------------- #
  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES" # Most compatible across different PVE nodes.
  }
  memory {
    dedicated = var.memory_mb
  }
  # Disks ---------------------------------------- #
  disk {
    datastore_id = var.disk_datastore # Defaults to 'local-lvm' if not provided.
    interface    = "scsi0"
    size         = var.disk_size_gb # 32GB
    cache = "writeback"
    discard = "on"
  }

  # Dynamically add an extra data disks if set.
  dynamic "disk" {
    for_each = var.data_disks
    content {
      datastore_id = var.disk_datastore
      interface    = disk.key # Use interface name as value.
      size         = disk.value # Disk size in GB.
      cache = "writeback"
      discard = "on"
    }
  }

  # Cloud-Init ------------------------------------ #
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
