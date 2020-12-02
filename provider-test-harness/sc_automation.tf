provider "azurerm" {
  version = ">=99.0.0"
  features {}
}

data "azurerm_resource_group" "test" {
  name = "testing"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_security_center_automation" "alerts" {
  name                = "send-alerts"
  location            = "uksouth"
  resource_group_name = data.azurerm_resource_group.test.name

  scopes = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  ]

  action {
    type        = "LogAnalytics"
    resource_id = "/subscriptions/6a42c4e8-afcd-4155-b25a-d1f9f6371ca6/resourcegroups/testing/providers/microsoft.operationalinsights/workspaces/bcdev"
  }

  source {
    event_source = "Alerts"
  }
}

resource "azurerm_security_center_automation" "assessments" {
  name                = "send-assessments"
  location            = "uksouth"
  resource_group_name = data.azurerm_resource_group.test.name

  scopes = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  ]

  action {
    type        = "LogAnalytics"
    resource_id = "/subscriptions/6a42c4e8-afcd-4155-b25a-d1f9f6371ca6/resourcegroups/testing/providers/microsoft.operationalinsights/workspaces/bcdev"
  }

  source {
    event_source = "Assessments"
  }
}
