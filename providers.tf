terraform {
  backend "azurerm" {
    resource_group_name  = "Data-Orchestration-Terraform"
    storage_account_name = "dataorchnewstorage"
    container_name       = "deployments"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}
