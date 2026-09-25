# =============================================================== #
# VARIABLES: Proxmox - Cluster Wide Definitions
# =============================================================== #

pve_cluster_options = {
    description = "Proxmox Cluster: Managed by Terraform\n"
    language    = "en"
    keyboard    = "en-us"
    mac_prefix  = "BC:24:11" # Proxmox default = 'BC:24:11'.
    crs_ha = "basic" # The number of active guests on each node is used to choose the best-fitting node for an HA resource.
    next_id = {
        lower = 200  # Next VM or container ID to use, starting point.
        upper = 9999 # Highest ID number VM or container can be assigned.
    }
}

# Proxmox: Resource Pools ------------------------------------- #
pve_pools = {
    pool-prd-1 = "Production Workloads 1"
    pool-prd-2 = "Production Workloads 2"
    pool-stg   = "Staging Workloads"
    pool-dev   = "Development Workloads"
    pool-tst   = "Test Workloads"
    pool-lab   = "Lab Workloads"
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
    "svc-terraform" = {
        comment = "Service Account: Terraform"
        enabled = true
        password_enabled = false
        token_enabled    = true
        realm   = "pve"
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
