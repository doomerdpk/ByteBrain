data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  tags                          = var.tags

  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  rbac_authorization_enabled     = true    
}
