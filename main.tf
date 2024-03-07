terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.2.0"

  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

module "ip2cr-test-suite" {
  source = "./modules/ip2cr_test_suite"
  ssh_key_file = var.ssh_key_file
}

output "ip2cr-testing-metadata" {
  value = [
    module.ip2cr-test-suite.ip2cr-vm-metadata,
    module.ip2cr-test-suite.ip2cr-lb-metadata
  ]
}
