output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "ingress_fqdn" {
  value = module.cluster_config.ingress_fqdn
}

output "connect_to_cluster" {
  value = "az aks get-credentials --resource-group ${var.rg_name} --name ${azurerm_kubernetes_cluster.aks.name}"
}