terraform {
    # Configure the backend to use Azure Storage blob storage for storing the Terraform state file.
    backend "azurerm" {
        resource_group_name   = "rg-backend"
        storage_account_name  = "sabackend12345678"
        container_name        = "tfstate-homelab"
        key                   = "homelab.tfstate"
        use_azuread_auth      = true # Use Entra ID authentication for secure access to the storage account, rather than using access keys.
    }
}
