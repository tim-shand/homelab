# Bootstrap: Azure Service Principal + Terraform Backend

The Azure configuration should only be performed **once**, therefore the setup process is **manual**.

As Terraform will be configured to use Azure Blob Storage for remote state, it needs a method of authenticating to Azure from within a pipeline.
The Service Principal identity provides a way to automate the authentication process.
Using RBAC role assignments ensures that the Service Principal can only perform data operations for a specific Storage Account.

> [!NOTE]
> This is required **BEFORE** any resources are deployed using Terraform or pipelines.

---

## ❔ Requirements

- Azure CLI installed _(if using terminal command option)_.
- **Entra ID:** Rights to create App Registration and Service Principal (`Application Developer` or higher).
- **Azure RBAC:** Rights to assign roles at the Storage Account scope (`Owner` or `User Access Administrator`).

> [!NOTE]
> The process below uses an _existing_ Azure subscription, Resource Group and Storage Account dedicated to Terraform IaC backend states.

---

## 🅰️ Option 1: Azure CLI

### Service Principal

1. Create the App Registration and Service Principal.

```bash
APP_DISPLAY_NAME="sp-iac-homelab"
APP_ID=$(az ad app create --display-name "$APP_DISPLAY_NAME" --query appId --output tsv)
az ad sp create --id "$APP_ID"
```

2. Create the Client Secret (will update with a new one for each subsequent run).

```bash
CLIENT_SECRET=$(az ad app credential reset --id "$APP_ID" --append --years 1 --query password --output tsv)
```

3. Print the results.

```bash
echo "Application (Client) ID: $APP_ID"
echo "Client Secret: $CLIENT_SECRET"
```

### Terraform Backend

1. Create Blob Container in an existing Resource Group and Storage Account.

```bash
SUBSCRIPTION_ID="<subscription-id>"
RESOURCE_GROUP="<resource-group-name>"
STORAGE_ACCOUNT="<storage-account-name>"
CONTAINER_NAME="<container-name>"
az storage container create --account-name "$STORAGE_ACCOUNT" --name "$CONTAINER_NAME" --auth-mode login
```

2. Assign RBAC role to Storage Account for Service Principal.

```bash
az role assignment create --role "Storage Blob Data Contributor" --assignee "$APP_ID" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
```

---

## 🅱️ Option 2: Azure Portal

### Service Principal

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

### Terraform Backend

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

---

## ▶️ Next Steps

- Ensure the App Registration (Service Principal) details, including the Client Secret, are stored securely.
- This will be needed by GitLab pipelines in future automation.
