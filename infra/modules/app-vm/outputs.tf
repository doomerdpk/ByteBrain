output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "identity" {
  description = "Managed identity assigned to the resource."
  value       = azurerm_linux_virtual_machine.this.identity
}

output "nic_id" {
  value = azurerm_network_interface.this.id
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

output "nsg_id" {
  value = azurerm_network_security_group.this.id
}