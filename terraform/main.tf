# =============================================================================
# main.tf -  Proveedor de Azure + grupo de recursos
# =============================================================================
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Si la variable 'subscription_id' no está vacía, se usa de forma automática
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = "casopractico2"
  }
}
