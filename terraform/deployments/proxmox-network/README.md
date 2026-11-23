# Proxmox: Network Configuration (SDN)

This stack contains the Terraform configuration used to deploy and manage Proxmox networking.

## 🧩 Components

- Software-defined Networking (SDN)
- Virtual networks, subnets and VLANs.

**Excluded:** DNS and DHCP is managed by OPNsense Firewall.

## ▶️ Usage

_Executed as part of the initial bootstrapping process, and in subsequent workflow runs._

1. Prepare local directory for initial run (update modules).

```bash
clear && terraform -chdir=./terraform/deployments/proxmox-network init -upgrade
```

2. Execute deployment, passing in variable files.

```bash
clear && terraform -chdir=./terraform/deployments/proxmox-network apply \
-var-file=../variables/proxmox-global.tfvars -var-file=../variables/proxmox-network.tfvars
```

---
