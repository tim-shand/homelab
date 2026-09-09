# Workflow Actions

## Proxmox: API Authentication

| Name                    | Type     | Description                              |
| ----------------------- | -------- | ---------------------------------------- |
| PVE_API_TERRAFORM_USER  | Variable | Proxmox API: Service Account (Terraform) |
| PVE_API_TERRAFORM_TOKEN | Secret   | Proxmox API: Auth Token (Terraform)      |
| PVE_API_PACKER_USER     | Variable | Proxmox API: Service Account (Packer)    |
| PVE_API_PACKER_TOKEN    | Secret   | Proxmox API: Auth Token (Packer)         |

## Azure: Terraform Remote State

Details of secrets and variables used to connect to Azure for remote state storage.

| Name                         | Type     | Description                            |
| ---------------------------- | -------- | -------------------------------------- |
| ARM_CLIENT_ID                | Secret   | Azure: Service Principal Client ID     |
| ARM_CLIENT_SECRET            | Secret   | Azure: Service Principal Client Secret |
| ARM_TENANT_ID                | Secret   | Azure: Entra Tenant ID                 |
| ARM_SUBSCRIPTION_ID          | Variable | Azure: Subscription ID                 |
| TF_BACKEND_RESOURCE_GROUP    | Variable | Azure: Backend Resource Group          |
| TF_BACKEND_STORAGE_ACCOUNT   | Variable | Azure: Backend Storage Account         |
| TF_BACKEND_STORAGE_CONTAINER | Variable | Azure: Backend Blob Container          |
