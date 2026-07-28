output "storage_account_name" {
  value = azurerm_storage_account.static.name
}

output "storage_account_id" {
  value = azurerm_storage_account.static.id
}

output "primary_web_endpoint" {
# used by Front Door    
# https://bytebrainfrontendprod01.z13.web.core.windows.net/
  value = azurerm_storage_account.static.primary_web_endpoint
}

output "primary_blob_endpoint" {
# https://bytebrainfrontendprod01.blob.core.windows.net/
  value = azurerm_storage_account.static.primary_blob_endpoint
}