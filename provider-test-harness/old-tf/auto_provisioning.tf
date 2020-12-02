provider "azurerm" {
  version = ">=99.0.0"
  features {}
}

#
# Test azurerm_security_center_auto_provisioning
#
# resource "azurerm_security_center_auto_provisioning" "example" {
#   auto_provision = "On"
# }
