provider "azurerm" {
  version = "~>2.20.0"
  features {}
}

data "azurerm_client_config" "current" {
}

locals {
  app_port = 3000
  app_name = "myapp"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.common["location"]
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "null_resource" "acr_import" {
  triggers = {
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    acr_name            = azurerm_container_registry.acr.name
    image_name          = var.image
    force_run           = "yes1"
  }

  depends_on = [azurerm_container_registry.acr]

  provisioner "local-exec" {
    command = <<EOF
         docker pull ${var.image} \
      && docker tag ${var.image} ${azurerm_container_registry.acr.login_server}/${var.image} \
      && docker login -u ${azurerm_container_registry.acr.admin_username} -p ${azurerm_container_registry.acr.admin_password} ${azurerm_container_registry.acr.login_server} \
      && docker push ${azurerm_container_registry.acr.login_server}/${var.image} \
      && sleep 5
      EOF
  }
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
  depends_on = [null_resource.acr_import]

  name                = "${var.prefix}-aci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "public"
  dns_name_label      = "${var.prefix}-${local.app_name}"
  os_type             = "Linux"

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  container {
    name = "my-app"
    # image  = var.image
    image  = "${azurerm_container_registry.acr.login_server}/${var.image}"
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
