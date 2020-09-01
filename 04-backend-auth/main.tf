provider "azurerm" {
  version = "~>2.20.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}
