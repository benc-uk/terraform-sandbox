provider "azurerm" {
  version = "~>2.20.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

locals {
  app_port = 3000
  app_name = "myapp"
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_rg
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.common["location"]
}

resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}sa"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test_share" {
  name                 = "test"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 1
}

resource "azurerm_container_group" "aci" {
  name                = "${var.prefix}-aci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "public"
  dns_name_label      = "${var.prefix}-${local.app_name}"
  os_type             = "Linux"

  image_registry_credential {
    server   = data.azurerm_container_registry.acr.login_server
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
  }

  container {
    name = local.app_name
    image  = "${data.azurerm_container_registry.acr.login_server}/${var.image}"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = local.app_port
      protocol = "TCP"
    }

    volume {
      name                 = "test"
      mount_path           = "/mnt/test"
      storage_account_name = azurerm_storage_account.storage.name
      storage_account_key  = azurerm_storage_account.storage.primary_access_key
      share_name           = azurerm_storage_share.test_share.name
    }
  }
}
