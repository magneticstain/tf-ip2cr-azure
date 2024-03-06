terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.2.0"

  # backend "s3" {}
}

provider "azurerm" {
  features {}
}

module "sample-module" {
  source = "./modules/sample_module"
}
