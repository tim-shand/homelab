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
  - Using scripts and automation tools to apply configuration to systems.
  - Prepare systems for future management by automation workflows.

3. **Phase 3: Automated**
  - Systems are now managed by automation workflows and Git-based operations.
  - Resources and configuration are defined in code (Terraform and Ansible).
  - Code changes are automatically deployed using pipelines/workflows.

---

## 1️⃣ Phase 1: Foundation (Manual, Run Once)

### 1. Physical Hardware & Networking

- Setup physical hardware and networking.
- Managed switch configured for VLANs using tagged and untagged ports with PVID.
- Azure Resource Group, Storage Account and Key Vault created for Terraform remote state.
- OPNsense installed or configuration imported from backup.

### 2. OPNsense Firewall

> [!WARNING]
> Preference is to **import** last known config from backup, rather than rebuild from scratch.

- Confirm VLANs are configured as per [configuration documentation](../docs/configuration.md).
- Firewall rules configured, enable trusted WAN and inter-VLAN connectivity (if required).
- DNS entries created in OPNsense Unbound (or imported if using backup).

### 3. Proxmox VE

- Install Proxmox VE manually on each node from USB image.
- Configure cluster, node membership, and initial storage (ZFS).
- **DO NOT CONFIGURE SDN:** This is to be managed by Terraform using workflows once Git server is bootstrapped.

---

## 2️⃣ Phase 2: Bootstrap (Script Driven)

### 1. Azure

> [!NOTE]
> This project utilises an existing Azure tenant and subscription resources. 
> Configuration is required **BEFORE** any project resources can be deployed, as this provides the remote state backend storage for Terraform.
> This is required **BEFORE** any resources are deployed using Terraform or pipelines.

#### Resources

- **Azure Blob Storage**
  - Used for remote Terraform state file storage.
  - Enables file locking, which prevents concurrent writes to the data.
  - Ensures only one workflow or execution can use the state file at a time to prevent corruption.

- **Service Principal (App Registration)**
  - Required to access the subscription level resources (storage account).
  - Provides a dedicated identity for authentication to Azure from within automation pipelines.
  - Uses RBAC role assignments to limit data operations to a specific Storage Account.

#### Requirements

- [x] Azure CLI installed and authenticated _(if using terminal command option)_.
- [x] **Entra ID:** Rights to create App Registration and Service Principal (`Application Developer` or higher).
- [x] **Subscription:** Created with `Contributor` role assigned to user identity.
- [x] **Azure RBAC:** Rights to assign roles at the Storage Account scope (`Owner` or `User Access Administrator`).

#### Process

**Service Principal**

1. Create the App Registration and Service Principal.

```bash
APP_DISPLAY_NAME="sp-iac-homelab"
APP_ID=$(az ad app create --display-name "$APP_DISPLAY_NAME" --query appId --output tsv)
az ad sp create --id "$APP_ID"
```

2. Create the Client Secret (will update with a new one for each subsequent run).

```bash
CLIENT_SECRET=$(az ad app credential reset --id "$APP_ID" --append --years 1 --query password --output tsv)
echo "Application (Client) ID: $APP_ID"
echo "Client Secret: $CLIENT_SECRET"
```

**Terraform Backend**

1. Create new Resource Group, Storage Account, and Blob Container in Azure subscription.

```bash
SUBSCRIPTION_ID="<subscription-id>"
REGION="<region-name>"
RESOURCE_GROUP="<resource-group-name>"
STORAGE_ACCOUNT="<storage-account-name>"
CONTAINER_NAME="<container-name>"

az group create --name "$RESOURCE_GROUP" --location "$REGION"
az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location "$REGION" --sku Standard_LRS --kind StorageV2
az storage container create --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER_NAME" --auth-mode login
```

2. Assign RBAC role to Storage Account for Service Principal.

```bash
az role assignment create --role "Storage Blob Data Contributor" --assignee "$APP_ID" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
```

> [!NOTE]
> Ensure the App Registration (Service Principal) details, including the Client Secret, are stored securely.
> This will be needed by GitLab pipelines in future automation.

### 2. Proxmox VE

This process provides the baseline configuration to get started.
Proxmox is configured using an Ansible playbook to apply the initial configuration needed to manage the cluster.
The playbook uses the `root` user account to create and configure service accounts which will be later used within automation workflows.

#### Actions

**Service Accounts:**

- Creates dedicated service account group in Proxmox and assigns required permissions by role.
- Creates **Terraform** and **Ansible** Proxmox users with API access.
  - Enables automated authentication during workflow operations.
- Creates Ansible service account **locally** on each Proxmox node.
  - Adds SSH public key to `authorized_users` file.
  - Configures passwordless `sudo` permissions for automated operations.
  - Required to perform administrative tasks at the OS layer (install/upgrade packages etc).

**VM Template:**
  
- Downloads Ubuntu Server cloud-init image.
- Installs guest agent and other required packages.
- Configures default root password.
- Converts the VM into VM template.

#### Process

1. Generate SSH key-pair and place the public key in the `ssh_keys` directory.

```bash
ssh-keygen -q -t ed25519 -N "" -C "<ansible_account>" -f "files/ssh_keys/<ansible_account>"
```

2. Confirm or update the inventory to ensure correct IP addressing.
3. Update the variables in the playbook `ansible/playbooks/bootstrap-proxmox.yml`.
4. Run the Ansible playbook to bootstrap Proxmox and generate a VM template.

> [!NOTE]
> Using the flag `--ask-pass` will require inputting the `root` account for Proxmox nodes.

```bash
cd ansible && ansible-playbook -i inventory/main.ini playbooks/bootstrap-proxmox.yml --ask-pass
```

### 3. Git Server (Gitea)

- Execute the [Gitea bootstrapping script](./gitea/) to setup server automatically.
  - Deploys a new VM in Proxmox using previously created VM template.
  - Downloads, installs and configures Gitea on the VM using Ansible.
  - Configures a local Gitea Runner on the VM for executing workflows.

> [!NOTE]
> This process currently requires manual configuration of the GitHub --> Gitea repo mirroring.

**From within the Gitea web interface:**

1. Select **New Migration** in the **Create** menu on the top right.
2. Enter the GitHub repository URL.
3. Enable the option **This repository will be a mirror**.
4. Select the migration items to bring across.
5. Select **Migrate Repository** to save the configuration.

---
