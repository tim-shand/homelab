terraform {
  backend "azurerm" { # Configure the backend to use Azure Storage blob storage for Terraform state file.
    resource_group_name   = "rg-myhomelab"
    storage_account_name  = "myhomelabstorageaccount"
    container_name        = "tfstate-homelab"
    key                   = "pve-cluster.tfstate"
    use_azuread_auth      = true # Use Entra ID authentication for secure access to the storage account, rather than using access keys.
  }
}
