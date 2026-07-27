# Initial Setup & Bootstrap Sequence

The process below describes the steps required to re-build the home lab environment from scratch.
With the majority of workloads being managed using Terraform, the home lab should be as reproducible as possible. 

Bootstrapping scripts are used to create resources that are required _before_ automation pipelines can take over.
The bootstrap process establishes the minimum infrastructure required for GitLab to take ownership of the environment.

## 1️⃣ Foundation State (Layer 0: Manual, Run Once)

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

The Azure configuration should only be performed **once**, therefore the setup process is **manual**.

As Terraform will be configured to use Azure Blob Storage for remote state, it needs a method of authenticating to Azure from within a pipeline.
The Service Principal identity provides a way to automate the authentication process.
Using RBAC role assignments ensures that the Service Principal can only perform data operations for a specific Storage Account.

> [!NOTE]
> This is required **BEFORE** any resources are deployed using Terraform or pipelines.

#### Service Principal

1. Login to Azure Portal and navigate to `Entra ID`.
2. Under the `Manage` menu, select `App Registrations`.
3. Click `New Registration`, providing a suitable name.
4. Ensure the option `Single Tenant Only` is selected (default).
5. Click Register.
6. Back on the `App Registrations` panel, select `All Applications`.
7. Select the newly created App Registration.
8. Navigate to `Certificates & Secrets`.
9. Select the section `Client Secrets`, click `New Client Secret`.
10. Enter a brief description, select an expiry timeframe, then click `Add`.
11. Once returned to the `Client Secrets` panel, copy the value and save it securely.
12. Under the `Overview` menu, take note of the following values: `Application (client) ID` and `Directory (tenant) ID`.

#### Terraform Backend

> [!NOTE]
> This process uses an _existing_ Azure subscription and resources dedicated to Terraform IaC backend states.

1. Login to Azure Portal and locate dedicated IaC Subscription.
2. Navigate to Resource Group (`*iac-backend`) and Storage Account (`*iacworkload`).
3. Under the `Data Storage` menu, select `Containers`.
4. Click `Add Container` and enter the name `tfstate-homelab`.
5. From within the Storage Account view, select `Access Control (IAM)`.
6. Select the `Add` dropdown, followed by `Add Role Assignment`.
7. Under the `Job Function Roles` section, locate and select `Storage Blob Data Contributor`, then click `Next`.
8. Select `User, group, or service principal`, followed by `+ Select Members`.
9. Search for the previously created Service Principal by name and click `Select`.
10. Click `Review + Assign`. 

### GitLab



---

## 2️⃣ Steady State (Layer 1: Pipeline Driven)

