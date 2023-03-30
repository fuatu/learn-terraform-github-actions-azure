terraform {

  backend "azurerm" {
    resource_group_name  = "FuatExperiments"
    storage_account_name = "terraformtestff"
    container_name       = "terraform"
    key                  = "app1.tfstate"
    subscription_id      = "b2020ded-fdab-492a-91e0-b4e04d9ef6df"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "testimg"

    workspaces {
      name = "learn-terraform-github-actions-azure"
    }
  }
}

