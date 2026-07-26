output "resource_group_id" {
  description = "Resource ID of the Bytebrain resource group"
  value       = module.bytebrain_rg.id
}

output "resource_group_name" {
  description = "Name of the Bytebrain resource group"
  value       = module.bytebrain_rg.name
}

output "resource_group_location" {
  description = "Location of the Bytebrain resource group"
  value       = module.bytebrain_rg.location
}