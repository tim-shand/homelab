# Proxmox: Network Configuration (SDN)

This stack contains the Terraform configuration used to deploy and manage Proxmox networking.

## ❓ Requirements

- Network bridges **must** be created manually before running this module.
- Navigate to `Node > System > Network > Create`.
- Create a new Linux Bridge named `vmbr1` to use with SDN and VLANs.

```text
Name: vmbr2
Autostart: Enabled
Bridge Ports: nic1 (or anything other than what is used by vmbr0)
VLAN IDs: 2-4096
```

> [!NOTE]
> Although node bridges can be created with Terraform, it is risky as failure may result in loss of access.

---

## 🧩 Components

- Software-defined Networking (SDN)
- Virtual networks, subnets and VLANs.

**Excluded:** DNS and DHCP are managed by OPNsense Firewall in this environment.

---

## ▶️ Usage

_Executed as part of the initial bootstrapping process, and in subsequent workflow runs._

1. Prepare local directory for initial run (update modules).

```bash
clear && terraform -chdir=./terraform/deployments/proxmox-network init -upgrade
```

2. Execute deployment, passing in variable files.

```bash
clear && terraform -chdir=./terraform/deployments/proxmox-network apply -var-file=../variables/proxmox-network.tfvars
```

---
