# ====================================================================== #
# Proxmox: Variables
# Description:
# - Variable definitions for Proxmox configuration.
# ====================================================================== #

# PROXMOX AUTHENTICATION -------------------------------------------- #

variable "pve_api_url" {
  description = "URL string used to connect to Proxmox API. To be passed via commandline or workflow secret."
  type        = string
}

variable "pve_api_user" {
  description = "Proxmox API service account for Terraform."
  type        = string
}

variable "pve_api_token" {
  description = "Proxmox API token for authentication, should be stored securely and passed in via environment variable or workflow secrets."
  type        = string
  sensitive   = true
}

# / --------------------------------------------------------- #

variable "pve_cluster_options" {
  description = "Define Proxmox cluster options."
  type = object({
    description = string
    language    = string
    keyboard    = string
    mac_prefix  = string
    crs_ha      = string
    next_id = object({
      lower = number
      upper = number
    })
  })
  validation {
    condition     = length(var.pve_cluster_options.mac_prefix) == 8
    error_message = "The value length required is 8 characters."
  }
  validation {
    condition     = can(regex("^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){2}$", var.pve_cluster_options.mac_prefix))
    error_message = "Value must be a valid MAC address prefix (first 3 octets only)."
  }
}

variable "pve_pools" {
  description = "Map of Proxmox cluster pools."
  type        = map(string)
}

# Proxmox: Identity ------------------------------------------------- #

variable "pve_iam_groups" {
  description = "Map of objects defining Proxmox groups and permissions."
  type = map(object({
    comment = string
    enabled = string
    acls    = map(string)
  }))
}

variable "pve_iam_users_svc" {
  description = "Map of objects defining Proxmox service accounts and group memberships."
  type = map(object({
    comment          = string
    enabled          = bool
    password_enabled = bool
    token_enabled    = bool
    realm            = string
    groups           = list(string)
  }))
}

# Proxmox: Backup Schedules ------------------------------------------------- #

variable "pve_backup_pools" {
  description = "Map of objects containing resource pools to backup."
  type = map(object({
    enabled = bool
    job_name = string
    schedule = string
    datastore = string
  }))
}

# Proxmox: Storage Configuration ------------------------------------------------- #

variable "pve_storage_nfs" {
  description = "Map of objects defining NFS storage in Proxmox cluster."
  type = map(object({
    enabled   = bool
    all_nodes = bool
    nodes     = list(string)
    server    = string
    export    = string
    options   = string
    content   = list(string)
    backups   = object({
      max_protected_backups = number  # The maximum number of protected backups per guest. Use '-1' for unlimited.
      keep_hourly           = number # The number of hourly backups to keep. Older backups will be removed.
      keep_daily            = number
      keep_weekly           = number
      keep_monthly          = number
    })
  }))
}
