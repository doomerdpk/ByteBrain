output "frontdoor_hostname" {
  description = "The default Azure Front Door endpoint hostname (e.g., <endpoint>.azurefd.net)."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "endpoint_id" {
  description = "The resource ID of the Azure Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "profile_id" {
  description = "The resource ID of the Azure Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "frontdoor_url" {
  description = "The HTTPS URL of the Azure Front Door endpoint."
  value       = "https://${azurerm_cdn_frontdoor_endpoint.this.host_name}"
}