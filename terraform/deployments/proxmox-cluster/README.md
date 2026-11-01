# Proxmox: Cluster Configuration

This stack contains the Terraform configuration used to deploy and manage the core Proxmox cluster settings.

## 🧩 Components

- **Cluster Settings**
  - System wide configuration settings (resource pools, language, node configs etc).

- **Identity and Access**
  - Service accounts and API tokens.
  - Group memberships and role assignments.

- **Software-defined Networking**
  - Virtual networks, subnets and VLANs.

## ▶️ Usage

_Executed as part of the initial bootstrapping process, and in subsequent workflow runs._

1. Prepare local directory for initial run (update modules).

```bash
clear && terraform -chdir=./terraform/deployments/proxmox-cluster init -upgrade
```

2. Execute deployment, passing in variable files.

```bash
clear && terraform -chdir=./terraform/deployments/proxmox-cluster apply \
-var-file=../variables/proxmox-global.tfvars -var-file=../variables/proxmox-cluster.tfvars
```

---
