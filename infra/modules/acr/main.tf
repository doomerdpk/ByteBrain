resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  admin_enabled = false

  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && length(var.allowed_ip_ranges) > 0 ? [1] : []
    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = var.allowed_ip_ranges
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      days    = var.untagged_retention_days
      enabled = true
    }
  }

  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplication_locations : []
    content {
      location                = georeplications.value
      zone_redundancy_enabled = true
      tags                    = var.tags
    }
  }

  zone_redundancy_enabled = var.sku == "Premium" ? var.zone_redundancy_enabled : false

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}