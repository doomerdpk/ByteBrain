locals {
  fd_name          = var.fd_name
  fd_endpoint_name = "${var.fd_name}-fd"
  origin_host_name = azurerm_storage_account.static.primary_web_host
}

# Premium/Standard Profile used to attach endpoints, origin groups, origins, routes, rules, and WAF policies.
resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = local.fd_name
  resource_group_name = var.resource_group_name
  sku_name            = var.front_door_sku

  tags = var.tags
}

# User accessible front door endpoint, which is the public entry point for the static site.
resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = local.fd_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  enabled                  = true

  tags = var.tags
}

# Origin Group is a logical container for one or more backend origins (Storage Account, App Service, AKS, etc.).
# It defines how Front Door checks backend health and distributes traffic.
resource "azurerm_cdn_frontdoor_origin_group" "static_site" {
  name                     = "og-static-site"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    # Considers the last 4 health probe results.
    sample_size                        = 4
    # At least 3 out of 4 probes must succeed for the backend to be considered healthy.
    successful_samples_required        = 3
  }

  health_probe {
    path                = "/"
    # HEAD returns only the response headers. No response body is downloaded. Faster and uses less bandwidth.
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

# Creates a backend origin that Azure Front Door forwards requests to.
resource "azurerm_cdn_frontdoor_origin" "static_site" {
  name                          = "origin-static-site"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.static_site.id

  enabled                         = true
  host_name                       = local.origin_host_name
  origin_host_header              = local.origin_host_name
  http_port                       = 80
  https_port                      = 443
  priority                        = 1
  weight                          = 1000
  certificate_name_check_enabled  = true
}

# Creates a route that tells Azure Front Door how to handle incoming requests and where to send them.
resource "azurerm_cdn_frontdoor_route" "static_site" {
  name                          = "route-static-site"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.static_site.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.static_site.id]

  supported_protocols    = ["Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true

  cache {
    # Ignores query parameters when caching.
    query_string_caching_behavior = "IgnoreQueryString"
    # Compresses supported files before sending them to clients, reducing bandwidth and improving
    compression_enabled           = true
    content_types_to_compress = [
      "text/html",
      "text/css",
      "text/javascript",
      "application/javascript",
      "application/json",
      "image/svg+xml",
    ]
  }
}

