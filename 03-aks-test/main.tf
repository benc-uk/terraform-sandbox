// ========== Set Up ==========

provider "azurerm" {
  version = "~>2.20.0"
  features {}
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_rg
}

locals {
  subnet_name = "aks-subnet"
}

// ========== Resources ==========

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}


resource "azuread_application" "aad_app" {
  name = "${var.prefix}-sp"
}

resource "azuread_service_principal" "sp" {
 application_id = azuread_application.aad_app.application_id
}

resource "random_password" "password" {
  length = 16
  special = true
}

resource "azuread_application_password" "aad_app_password" {
  application_object_id = azuread_application.aad_app.id
  value                 = random_password.password.result
  end_date              = "2040-01-01T00:00:00Z"
  description           = "TF generated password"
}

resource "null_resource" "delay_for_aad" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [ azuread_service_principal.sp ]
}

//
// Vnet and subnet for AKS in "advanced" network mode
//
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [ var.vnet_address_space ]

  subnet {
    name           = local.subnet_name
    address_prefix = var.vnet_aks_subnet_cidr
  }
}

//
// Log Analytics 
//
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.prefix}-akslogs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

//
// Provision public IP for ingress
//
resource "azurerm_public_ip" "ingress_public_ip" {
  name                = "${var.prefix}-ingress-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

//
// The main cluster
//
resource "azurerm_kubernetes_cluster" "aks" {
  depends_on          = [ azuread_application_password.aad_app_password ]
  name                = "${var.prefix}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}-aks"
  kubernetes_version  = var.aks_kube_version

  default_node_pool {
    name                = "default"
    node_count          = var.aks_node_count
    vm_size             = var.aks_node_size
    enable_auto_scaling = true
    min_count           = var.aks_node_count
    max_count           = 10
    vnet_subnet_id      = "${azurerm_virtual_network.vnet.id}/subnets/${local.subnet_name}"
  }

  service_principal {
    client_id      = azuread_service_principal.sp.application_id
    client_secret  = random_password.password.result
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
    }
  }
}

//
// Assign the AKS SP "Monitoring Metrics Publisher" role for Azure Monitoring
//
resource "azurerm_role_assignment" "fast_alerting" {
  scope                            = azurerm_kubernetes_cluster.aks.id
  role_definition_name             = "Monitoring Metrics Publisher"
  // Gotcha - This needs to be the SP 'id' (i.e. AAD object id) NOT the 'application_id'
  principal_id                     = azuread_service_principal.sp.id
  skip_service_principal_aad_check = true
}

//
// Assign the AKS SP "Network Contributor" role on resource group, otherwise it can't assign the IP to the ingress
//
resource "azurerm_role_assignment" "network_contrib" {
  scope                            = azurerm_resource_group.rg.id
  role_definition_name             = "Network Contributor"
  // Gotcha - This needs to be the SP 'id' (i.e. AAD object id) NOT the 'application_id'
  principal_id                     = azuread_service_principal.sp.id
  skip_service_principal_aad_check = true
}

//
// Assign the AKS SP "ACR Pull" role on ACR, to allow k8s nodes to pull images from ACR
//
resource "azurerm_role_assignment" "acr_pull" {
  scope                            = data.azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  // Gotcha - This needs to be the SP 'id' (i.e. AAD object id) NOT the 'application_id'
  principal_id                     = azuread_service_principal.sp.id
  skip_service_principal_aad_check = true
}

//
// Deploy in-cluster resources and configuration
//
module "cluster_config" {
  source = "./cluster-config"

  cluster_fqdn               = azurerm_kubernetes_cluster.aks.fqdn
  cluster_client_key         = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  cluster_client_certificate = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  cluster_ca_certificate     = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate

  ingress_public_ip     = azurerm_public_ip.ingress_public_ip.ip_address
  ingress_public_ip_rg  = azurerm_public_ip.ingress_public_ip.resource_group_name
  dns_zone_name         = var.dns_zone_name
  dns_zone_rg           = var.dns_zone_rg
}
