output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.id
}

output "vmss_principal_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.identity[0].principal_id
}