resource "azurerm_linux_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.app_service_plan_id
  virtual_network_subnet_id = var.virtual_network_subnet_id

  identity {
    type = "SystemAssigned"
  }

  https_only              = true
  client_affinity_enabled = false

  site_config {
    linux_fx_version = "DOCKER|${var.container_image}"
  }

  app_settings = var.app_settings
  tags         = var.tags
}
