# =============================================================== #
# VARIABLES: Proxmox - Cluster Wide Definitions
# =============================================================== #

# Proxmox: Cluster Configuration ------------------------------------- #

pve_cluster_options = {
    description = "Proxmox Cluster: Managed by Terraform\n"
    language    = "en"
    keyboard    = "en-us"
    mac_prefix  = "BC:24:11" # Proxmox default = 'BC:24:11'.
    crs_ha      = "basic" # The number of active guests on each node is used to choose the best-fitting node for an HA resource.
    next_id = {
        lower = 200  # Next VM or container ID to use, starting point.
        upper = 9999 # Highest ID number VM or container can be assigned.
    }
}

# Proxmox: Resource Pools ------------------------------------- #

pve_pools = {
    pool-prd-1 = "Production Workloads 1"
    pool-prd-2 = "Production Workloads 2"
    pool-dev   = "Development Workloads"
    pool-tst   = "Test Workloads"
    pool-lab   = "Lab Workloads"
}

# Proxmox: Backup ------------------------------------- #

pve_backup_pools = {
  "pool-prd-1" = {
    enabled   = true
    job_name  = "pool-prd-1_daily_0200"
    schedule  = "*-*-* 02:00" # Daily at 02:00.
    datastore = "pve-smb-shared"
  }
  "pool-prd-2" = {
    enabled   = true
    job_name  = "pool-prd-2_daily_0400"
    schedule  = "*-*-* 04:00" # Daily at 04:00.
    datastore = "pve-smb-shared"
  }
}

# Proxmox: Identity & Access ------------------------------------- #

# Map to new or existing PVE role. Map 'scope' to 'path' in PVE console to determine access level.
pve_iam_groups = {
    "grp-pve-admins"     = {
        comment = "Privileged: Proxmox Console Administrators"
        enabled = true
        acls = {
            "Administrator" = "/"
        }
    }
    "grp-svc-automation" = {
        comment = "Privileged: Automation Service Accounts"
        enabled = true
        acls = {
            "Administrator" = "/"
        }
    }
    "grp-svc-monitoring" = {
        comment = "Read Only: Monitoring Service Accounts"
        enabled = true
        acls = {
            "PVEAuditor" = "/"
        }
    }
}

pve_iam_users_svc = {
    "svc-ansible" = {
        comment = "Service Account: Ansible"
        enabled          = true   # Enable/disable user account creation.
        password_enabled = false  # Enable for service accounts that cannot use API token.
        token_enabled    = true   # Enable to generate API token for authentication.
        realm   = "pam"           # Use 'pam' for local host level account, use 'pve' for Proxmox user only.
        groups = ["grp-svc-automation"]
    }
    "svc-monitor" = {
        comment = "Service Account: Monitoring"
        enabled = true
        password_enabled = true
        token_enabled    = true
        realm   = "pve"
        groups = ["grp-svc-monitoring"]
    }
}

# Proxmox: Storage ------------------------------------- #

pve_storage_nfs = {
    "shared-nfs-01" = {
        enabled   = true
        all_nodes = true              # Enable the storage share for all nodes (cancels variable 'nodes').
        nodes     = []                 # List of node names to if only required on specific nodes.
        server    = "10.0.10.10"       # The IP address or DNS name of the NFS server.
        export    = "/exports/proxmox" # The path of the NFS export.
        options   = "vers=4.2"         # Version of NFS protocol to use (3, 4, 4.1, 4.2).
        content   = ["images","iso","backup","import","rootdir","snippets","vztmpl"]
        backups = {
            max_protected_backups = 5  # The maximum number of protected backups per guest. Use '-1' for unlimited.
            keep_hourly           = 12 # The number of hourly backups to keep. Older backups will be removed.
            keep_daily            = 7
            keep_weekly           = 4
            keep_monthly          = 3
        }
    }
}
