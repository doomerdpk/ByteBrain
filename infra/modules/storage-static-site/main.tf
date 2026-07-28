resource "azurerm_storage_account" "static" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"

  https_traffic_only_enabled = true
  min_tls_version             = "TLS1_2"
  shared_access_key_enabled   = false

  tags = var.tags
}

resource "azurerm_storage_account_static_website" "static_website" {
  storage_account_id = azurerm_storage_account.static.id

  index_document     = var.index_document
  error_404_document = var.error_404_document
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "static_site_storage_access" {
  scope                = azurerm_storage_account.static.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}