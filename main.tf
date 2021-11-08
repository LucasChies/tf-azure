terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }

}

provider "azurerm" {
  features {}
}

#create resource group
resource "azurerm_resource_group" "rg" {
    name     = "tf-aks-rg"
    location = "eastus2"

    tags = {
    environment = "Dev"
    project   = "Terraform"
    owner     = "Lucas.Chies"
    }

}

#Create aks
module "aks" {
  source                 = "./aks-module"
}
