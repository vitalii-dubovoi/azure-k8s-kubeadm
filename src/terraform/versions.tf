terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0"
    }
  }
}

provider "azurerm" {
  features {}

  client_id       = var.personal_clientid
  client_secret   = var.personal_client_secret
  tenant_id       = var.personal_tenantid
  subscription_id = var.personal_subscriptionid
}

