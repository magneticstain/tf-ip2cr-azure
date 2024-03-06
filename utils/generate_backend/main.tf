terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  project_name = "ip-2-cloudresource"
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tf-backend-${local.project_name}"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfbackendip2cr${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tf-backend-${local.project_name}"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

output "tf-backend-metadata" {
  value = [
    resource.azurerm_resource_group.tfstate.name,
    resource.azurerm_storage_account.tfstate.name,
    resource.azurerm_storage_container.tfstate.name
  ]
}