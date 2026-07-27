output "id" {
  value = azurerm_container_registry.this.id
}

output "name" {
  value = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Registry login server, e.g. bytebrainacr.azurecr.io"
  value       = azurerm_container_registry.this.login_server
}