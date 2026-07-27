# Initial Setup & Bootstrap Sequence

The process below describes the steps required to re-build the home lab environment from scratch.
With the majority of workloads being managed using Terraform, the home lab should be as reproducible as possible. 

Bootstrapping scripts are used to create resources that are required _before_ automation pipelines can take over.
The bootstrap process establishes the minimum infrastructure required for GitLab to take ownership of the environment.

## 1️⃣ Foundation State (Layer 1: Manual, Run Once)

### Physical Hardware & Networking

- Setup physical hardware and networking.
- Managed switch configured for VLANs using tagged and untagged ports with PVID.
- Azure Resource Group, Storage Account and Key Vault created for Terraform remote state.
- OPNsense installed or configuration imported from backup.

### OPNsense Firewall

> [!WARNING]
> Preference is to import last known config from backup, rather than rebuild.

- Confirm VLANs are configured as per [configuration documentation](../docs/configuration.md).
- Firewall rules configured, enable trusted WAN and inter-VLAN connectivity (if required).
- DNS entries created in OPNsense Unbound (or imported via backup).

### Proxmox

- Install Proxmox VE on each node.
- Configure cluster, node membership, and storage (ZFS) only from web UI.
  - **DO NOT CONFIGURE SDN:** This is to be managed by Terraform via pipeline.
- Run [Proxmox bootstrap script](./proxmox/README.md) to setup service account and API access.
  - Proxmox API token to be saved to Azure Key Vault (or Password Manager).
  - Downloads Ubuntu Server cloud-init image and configures VM template.

### Azure

> [!NOTE]
> This is required **BEFORE** any resources are deployed using Terraform or pipelines.

- Deploy App Registration (Service Principal).
- Deploy Blob Container in existing Resource Group and Storage Account.
- Refer to [the deployment guide](./azure/README.md) for further details.

### GitLab



---

## 2️⃣ Steady State (Layer 2: Pipeline Driven)

