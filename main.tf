terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {}
}

provider "aws" {
  region  = "us-east-1"

  assume_role {
    # aws account alias is set as the name of the TF workspace and derived from that
    role_arn = var.accounts[terraform.workspace]
  }
}

module "sample-module" {
  source = "./modules/sample_module"
}
