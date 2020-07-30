provider "azurerm" {
  version = "~>2.20.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
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
  }

  depends_on = [azurerm_container_registry.acr]

  provisioner "local-exec" {
    command = "az login --service-principal -u ${var.client_id} -p ${var.client_secret} --tenant ${var.tenant_id}"
  }
  provisioner "local-exec" {
    command = "az acr import --name ${azurerm_container_registry.acr.name} --source docker.io/${var.image} --force && sleep 5"
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
  dns_name_label      = "${var.prefix}-my-app"
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
      port     = 3000
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
