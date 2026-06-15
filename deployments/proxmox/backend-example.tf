terraform {
  backend "azurerm" { # Configure the backend to use Azure Storage blob storage for storing the Terraform state file.
    resource_group_name   = "rg-tjs-iac-backend"
    storage_account_name  = "satjsiacworkload704426"
    container_name        = "tfstate-homelab"
    key                   = "pve-cluster.tfstate"
    use_azuread_auth      = true # Use Entra ID authentication for secure access to the storage account, rather than using access keys.
  }
}
