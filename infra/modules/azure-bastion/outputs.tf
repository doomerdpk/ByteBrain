output "bastion_host_id" {
  value = azurerm_bastion_host.this.id
}

output "bastion_host_name" {
  value = azurerm_bastion_host.this.name
}

output "bastion_public_ip_address" {
  value = azurerm_public_ip.bastion.ip_address
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "nsg_id" {
  value = azurerm_network_security_group.bastion.id
}