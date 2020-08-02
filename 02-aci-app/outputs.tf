output "app_url" {
  value = "http://${azurerm_container_group.aci.dns_name_label}.${azurerm_container_group.aci.location}.azurecontainer.io:${local.app_port}"
}