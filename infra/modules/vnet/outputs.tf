output "id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "address_space" {
  description = "The address spaces configured on the Virtual Network."
  value       = azurerm_virtual_network.this.address_space
}

output "guid" {
  description = "The resource GUID of the Virtual Network."
  value       = azurerm_virtual_network.this.guid
}