terraform {
  required_version = ">= 0.12.0"

  backend "azurerm" {
    key = "aci-app.terraform.tfstate"
  }
}