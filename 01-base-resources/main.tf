provider "azurerm" {
  version = "~>2.20.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.common["location"]
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}acr"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
}
