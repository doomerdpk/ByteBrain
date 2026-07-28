resource "azurerm_storage_account" "static" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"

  https_traffic_only_enabled = true
  min_tls_version             = "TLS1_2"

  static_website {
    index_document     = var.index_document
    error_404_document = var.error_404_document
  }

  shared_access_key_enabled = false

  tags = var.tags
}
