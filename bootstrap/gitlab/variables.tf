# ====================================================================== #
# Proxmox: Bootstrap Variables
# Description:
# - Variable definitions for Proxmox bootstrap configuration.
# ====================================================================== #

variable "bootstrap_pve_un" {
  description = "Proxmox default root account."
  type = string
  default = "root@pam"
}

variable "bootstrap_pve_pw" {
  description = "Proxmox root password for authentication, prompted for input during runtime."
  type = string
  sensitive = true
}

variable "bootstrap_pve_node" {
  description = "Map of a single Proxmox node in the cluster. Used for one-off bootstrapping run."
  type = object({
    hostname    = string # Hostname of the primary Proxmox node, used for API access and resource targeting.
    ip_address  = string # IP address of the primary Proxmox node.
  })
}

variable "gitlab_ubuntu_template" {
  description = "The LXC template to use for the local GitLab container."
  type = string
  default = "ubuntu-26.04-standard_26.04-1_amd64.tar.zst" # http://download.proxmox.com/images/system/
}
