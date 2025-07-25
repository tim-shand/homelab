terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.37"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
  backend "azurerm" {
    resource_group_name   = var.tfbackend_resourcegroup
    storage_account_name  = var.tfbackend_storageaccount
    container_name        = var.tfbackend_container
    key                   = var.tfbackend_key
  }
}

provider "azapi" {
  tenant_id         = var.tenant_id
  subscription_id   = var.subscription_id
  client_id         = var.client_id
  client_secret     = var.client_secret
}

provider "azurerm" {
  tenant_id         = var.tenant_id
  subscription_id   = var.subscription_id
  client_id         = var.client_id
  client_secret     = var.client_secret

  features {}
}