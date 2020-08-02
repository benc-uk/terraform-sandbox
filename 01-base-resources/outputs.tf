output "location" {
  value = var.common["location"]
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}
