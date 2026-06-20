variable "pve_connection" {
  description = "Proxmox host and service account API token. Used to authenticate to Proxmox."
  type = object({
    hostname   = string # Proxmox node hostname.
    ip_address = string # Proxmox node IP address.
    api_token  = string # Full API token string used for service account. Example: terraform@pve!token=12345-ABCD-1234-ABCD-123456789
  })
}

variable "ssh_public_key" {
  description = "Public key used for connecting to te container via SSH."
  type = string
}

variable "container_image_url" {
  description = "The LXC template URL to use for the local GitLab container."
  type = string
  default = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

variable "container_config" {
  description = "Object of values defining the container configuration settings."
  type = object({
    pve_datastore_id  = string
    vmid              = number
    hostname          = string
    os_type           = string
    cpu = object({
      architecture = string # Must be one of "amd64", "arm64", "armhf", "i386".
      cores        = number # Number of cores available to workload.
    })
    memory = object({
      dedicated = number # Amount of dedicated memory in megabytes.
      swap      = number # Swap size in megabytes.
    })
    disk = object({
      datastore_id  = string
      size          = number
    })
    network = object({
      name    = string # Name to use for the network interface (eth0).
      bridge  = string # Proxmox node host bridge (vmbr0, vmbr1).
      ipv4    = string # Full IPv4 CIDR address. Example: 10.0.0.1/24.
      gateway = string # IP address of network gateway (10.0.0.254).
      vlan_id = string # "15"
      dns_domain = string # "servers.mydomain.com"
      dns_servers = list(string) # ["1.1.1.1","8.8.8.8"]
    })
  })
  validation {
    condition = contains(["amd64", "arm64", "armhf", "i386"],var.container_config.cpu.architecture)
    error_message = "CPU architecture must be one of: amd64, arm64, armhf, i386."
  }
  validation {
    condition = var.container_config.cpu.cores >= 1
    error_message = "CPU core must be greater than or equal to 1."
  }
  validation {
    condition = var.container_config.memory.dedicated >= 2048
    error_message = "Dedicated memory for container should be greater than or equal to 2 GB."
  }
  validation {
    condition = var.container_config.memory.swap >= 512
    error_message = "Swap size should be greater than or equal to 512 MB."
  }
  validation {
    condition = var.container_config.disk.size >= 40
    error_message = "Disk size should be greater than or equal to 40 GB."
  }
}