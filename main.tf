terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurern = {
      source  = "hashicor/azurerm"
      version = "~>4.4.0"
    }
  }
}

provider "azurerm" {
  feature {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "openarch" {
  name     = "rg-${var.prefix}"
  location = var.location
}

