# Proxmox: Cluster-wide Options ------------------------------------- #
pve_cluster_options = {
    description = "Proxmox Cluster\n"
    email_from  = "alerts@pve.int"
    language    = "en"
    keyboard    = "en-us"
    mac_prefix  = "BC:24:11" # Proxmox default = 'BC:24:11'.
    next_id = {
        lower = 200 # Next VM or container ID to use, starting point.
        upper = 900 # Highest ID number VM or container can be assigned.
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
        enabled = true
        realm   = "pam" # Use 'pam' for local host level account, use 'pve' for Proxmox user only.
        groups = ["grp-svc-automation"]
    }
    "svc-terraform" = {
        comment = "Service Account: Terraform"
        enabled = true
        realm   = "pve" # Use 'pam' for local host level account, use 'pve' for Proxmox user only.
        groups = ["grp-svc-automation"]
    }
}

# Proxmox: Node Configuration ------------------------------------- #
pve_nodes = {
    "node1" =  {
        node_name = "inf-hvr-pve-01"
        description = "Proxmox Node 1: Managed by Terraform | Storage=Local,ZFS | Dual NIC"
        hostname = "inf-hvr-pve-01.mgt.tshand.net"
        production = true
        network = {
            ip_address = "10.0.10.1"
            cluster = {
                interface = "nic0"
                bridge = "vmbr0"
            }
            guest = {
                interface = "nic1"
                bridge = "vmbr1"
            }
        }
    }
    "node2" =  {
        node_name = "inf-hvr-pve-02"
        description = "Proxmox Node 2: Managed by Terraform | Storage=Local,ZFS | Dual NIC"
        hostname = "inf-hvr-pve-02.mgt.tshand.net"
        production = true
        network = {
            ip_address = "10.0.10.2"
            cluster = {
                interface = "nic0"
                bridge = "vmbr0"
            }
            guest = {
                interface = "nic1"
                bridge = "vmbr1"
            }
        }
    }
    "node3" =  {
        node_name = "inf-hvr-pve-03"
        description = "Proxmox Node 3: Managed by Terraform | Storage=Local | Single NIC"
        hostname = "inf-hvr-pve-03.mgt.tshand.net"
        production = false
        network = {
            ip_address = "10.0.10.3"
            cluster = {
                interface = "nic0"
                bridge = "vmbr0"
            }
            guest = {
                interface = "nic0"
                bridge = "vmbr0"
            }
        }
    }
}

# Proxmox: Software Defined Networking ------------------------------------- #
pve_sdn_vnets = {
    "mgt10" = {
        id            = "mgt10"
        vlan_tag      = 10
        isolate_ports = false
        vlan_aware    = false
        subnets = {
            "mgt10_1" = {
                cidr_address = "10.0.10.0/24"
                gateway      = "10.0.10.254"
            }
        }
    }
    "svr20" = {
        id            = "svr20"
        vlan_tag      = 20
        isolate_ports = false
        vlan_aware    = false
        subnets = {
            "svr20_1" = {
                cidr_address = "10.0.20.0/24"
                gateway      = "10.0.20.254"
            }
        }
    }
}
