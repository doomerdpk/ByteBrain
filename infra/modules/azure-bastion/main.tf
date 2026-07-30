locals {
  session_recording_enabled   = var.sku == "Premium" ? var.enable_session_recording : false
  advanced_features_supported = contains(["Standard", "Premium"], var.sku)
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.bastion_subnet_address_prefix]
}

resource "azurerm_network_security_group" "bastion" {
  name                = "${var.bastion_host_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

# Bastion is accessed over HTTPS/TLS on port 443 (this is how you reach the Bastion portal/session in the Azure Portal or native client).
  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowed_source_address_prefixes
    destination_address_prefix = "*"
  }

# This is for Microsoft's backend needs to communicate with the Bastion host for control-plane operations
  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    # this isn't a real IP range you define; it's a built-in Azure service tag. Azure resolves this internally to the IP ranges used by Azure's own control-plane/management infrastructure
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

# Azure Bastion is a managed, highly-available PaaS service — internally, it runs behind Azure's infrastructure load balancer, even though you don't see or manage that load balancer directly. Azure's load balancer periodically sends health probes to the Bastion host to check that it's alive and responsive.
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

# When Bastion is deployed with more than one instance (i.e., scale_units > 2, or Standard/Premium SKU with autoscaling), the individual Bastion instances need to talk to each other for internal coordination — session management, load distribution across instances, and keeping cluster state in sync.

# Port 8080 — used for internal control-plane communication between Bastion instances.
# Port 5701 — used for Hazelcast, the in-memory data grid technology Bastion uses internally for session state clustering across scaled-out instances.

  security_rule {
    name                        = "AllowBastionHostCommunicationInbound"
    priority                    = 130
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_ranges     = ["8080", "5701"]
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "VirtualNetwork"
  }

# a user connects to Bastion over HTTPS (port 443, covered by the earlier inbound rule), and Bastion then relays that session internally to the target VM over SSH or RDP. Without this outbound rule, Bastion could accept the initial HTTPS connection from the user but would have no way to actually reach and connect to the destination VM)

  security_rule {
    name                          = "AllowSshRdpOutbound"
    priority                      = 100
    direction                     = "Outbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_range             = "*"
    destination_port_ranges       = ["22", "3389"]
    source_address_prefix         = "*"
    destination_address_prefixes  = var.target_vnet_address_space
  }

# Bastion, being a managed PaaS service, needs to talk back to Azure's own backend infrastructure
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

# This is the outbound counterpart to AllowBastionHostCommunicationInbound. When Bastion is deployed with multiple scale units (Standard/Premium SKU), each Bastion instance needs to both send and receive coordination traffic to/from its peer instances.
  security_rule {
    name                        = "AllowBastionHostCommunicationOutbound"
    priority                    = 120
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_ranges     = ["8080", "5701"]
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "VirtualNetwork"
  }

# Microsoft's official Bastion documentation requires this rule to retrieve session information and to perform certificate revocation list (CRL) checks — part of validating the TLS certificates involved in Bastion's connections. Certificate validation infrastructure (like CRL distribution points) is often served over plain HTTP rather than HTTPS, which is why port 80 (not 443) is specifically required here, even though everything else in this NSG is HTTPS.
  security_rule {
    name                       = "AllowGetSessionInformationOutbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.bastion_host_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.sku == "Premium" ? ["1", "2", "3"] : null
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags

  scale_units = local.advanced_features_supported ? var.scale_units : null

  tunneling_enabled          = local.advanced_features_supported ? var.enable_tunneling : false
  ip_connect_enabled         = local.advanced_features_supported ? var.enable_ip_connect : false
  shareable_link_enabled     = local.advanced_features_supported ? var.enable_shareable_link : false
  kerberos_enabled           = local.advanced_features_supported ? var.enable_kerberos : false
  session_recording_enabled  = local.session_recording_enabled

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.bastion]
}

# Bastion audit logs are usually considered a baseline security control (since Bastion is your privileged access chokepoint)
resource "azurerm_monitor_diagnostic_setting" "bastion" {
# count is a Terraform meta-argument that controls how many instances of a resource get created.
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.bastion_host_name}-diag"
  target_resource_id         = azurerm_bastion_host.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
