# 🥾 Home Lab: Bootstrap Sequence & Initial Setup

The process below describes the steps required to re-build the home lab environment from scratch.  
With the majority of workloads being managed using Terraform and Ansible, the home lab should be as reproducible as possible. 

Bootstrapping scripts are used to create resources that are required _before_ automation pipelines can take over.  
The bootstrap process establishes the minimum infrastructure required for Git-based workflows to over management of the environment.

_There are three phases involved:_

1. **Phase 1: Foundation**
  - Physical setup of hardware and components.
  - Installation of systems for bare metal infrastructure.

2. **Phase 2: Bootstrap**
  - Using scripts to automate the configuration of systems.
  - Prepare systems for future management by automation workflows.

3. **Phase 3: Automated**
  - Systems are now managed by automation workflows and Git-based operations.
  - Resources and configuration are defined in code (Terraform and Ansible).
  - Code changes are automatically deployed using pipeline/workflows.

---

## 1️⃣ Phase 1: Foundation (Manual, Run Once)

### 1. Physical Hardware & Networking

- Setup physical hardware and networking.
- Managed switch configured for VLANs using tagged and untagged ports with PVID.
- Azure Resource Group, Storage Account and Key Vault created for Terraform remote state.
- OPNsense installed or configuration imported from backup.

### 2. OPNsense Firewall

> [!WARNING]
> Preference is to import last known config from backup, rather than rebuild.

- Confirm VLANs are configured as per [configuration documentation](../docs/configuration.md).
- Firewall rules configured, enable trusted WAN and inter-VLAN connectivity (if required).
- DNS entries created in OPNsense Unbound (or imported via backup).

### 3. Proxmox VE

- Install Proxmox VE on each node.
- Configure cluster, node membership, and storage (ZFS) only from web UI.
- **DO NOT CONFIGURE SDN:** This is to be managed by Terraform via pipeline later on.

---

## 2️⃣ Phase 2: Bootstrap (Script Driven)

### 1. Azure

> [!NOTE]
> This project utilises an existing Azure tenant and resources. 
> Configuration is required **BEFORE** any project resources can be deployed as it provides the remote state backend storage for Terraform.

- Deploy App Registration (Service Principal) to provide authentication in workflows.
- Deploy Blob Container in existing Resource Group and Storage Account.
- Refer to [the deployment guide](./azure/) for further details.

### 2. Proxmox VE

- Run [Proxmox bootstrap scripts](./proxmox/) to configure VM template and setup service account for API access.

**Accounts:**

- Creates dedicated service account group in Proxmox and assigns required permissions by role.
- Creates **Terraform** service account in Proxmox for API access.
  - Proxmox API token to be _manually_ saved to Azure Key Vault or Password Manager.
- Creates **Ansible** service account locally on each Proxmox node in the cluster (defined by variable).
  - Required to perform administrative tasks at the OS layer (install/upgrade packages etc).

**VM Template:**
  
- Downloads Ubuntu Server cloud-init image and configures a VM template.
- Distribution determined by variable value.

### 3. Gitea

- Execute the [Gitea bootstrapping script](./gitea/) to setup server automatically.
  - Deploys a new VM in Proxmox using previously created VM template.
  - Downloads, installs and configures Gitea on the VM.
  - Configures a local Gitea Runner on the VM for executing workflows.

> [!NOTE]
> This process requires manual configuration of the GitHub --> Gitea repo mirroring.

From within the Gitea web interface:

1. Select **New Migration** in the **Create** menu on the top right.
2. Enter the GitHub repository URL.
3. Enable the option **This repository will be a mirror**.
4. Select the migration items to bring across.
5. Select **Migrate Repository** to save the configuration.

---
