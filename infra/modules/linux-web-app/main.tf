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
  application_stack {
        docker_image_name = var.container_image
    }
    container_registry_use_managed_identity = true
  }
  app_settings = var.app_settings
  tags         = var.tags
}
