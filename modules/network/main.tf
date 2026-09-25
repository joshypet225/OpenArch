resource "azurerm_virtual_network" "openarch" {
  name = "${var.prefix}-vnet"
  location = var.location
  resource_group_name = var.resource_group_name
  address_space = "10.0.0.0/16"
}

resource "azurerm_subnet" "openarch" {
  for_each = var.subnets
  name = each.key
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.openarch.name
  address_prefixes = each.value
}

resource "azurerm_network_security_group" "openarch"{
   for_each = var.nsg
   name = each.key
   location = var.location
   resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "openarch"{
    for_each = {
     for nsg_name, nsg_obj in var.nsg:
      for rule in nsg_obj.security_rule:
       "${nsg_name}-${rule.name}"=>{
         nsg_name = nsg_name                 
         rule = rule
       }
    }
    name = each.value.rule.name
    priority = each.value.rule.priority
    direction = each.value.rule.direction
    access = each.value.rule.access
    protocol = each.value.rule.protocol
    source_port_range = each.value.rule.source_port_range
    destination_port_range = each.value.rule.destination_port_range
    resource_group_name = azurerm_resource_group.openarch.name
    network_security_group_name = azurerm_network_security_group.openarch[each.key.nsg_name].name
    source_address_prefix = each.value.rule.source_address_prefix
    destination_address_prefix = each.value.rule.destination_address_prefix 
}

resource "azurerm_public_ip" "openarch" {
    for_each = toset(var.public_ip)
    name = "${each.key}-ip"
    location = var.location
    resource_group_name = var.resource_group_name
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_bastion_host" "openarch" {
    name = "${var.prefix}-bastion"
    location = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
	name = "configuration"
	subnet_id = azurerm_subnet.openarch["AzureBastionHostSubnet"].id
	public_ip_address_id = azurerm_public_ip.openarch["bastion"].id
    }
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.openarch.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.openarch.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.openarch.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.openarch.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.openarch.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.openarch.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.openarch.name}-rdrcfg"
}

resource "azurerm_application_gateway" "openarch" {
  name                = "${var.prefix}-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.openarch["gatewaySubnet"].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.openarch["gateway"].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "azurerm_lb" "openarch" {
  name                = "${var.prefix}-LoadBalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PrivateIPAddress"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "openarch" {
  for_each = toset($var.lb_backend_address_pool)
  loadbalancer_id = azurerm_lb.openarch.id
  name            = "${each.key}-backend_address_pool"
}

resource "azurerm_lb_probe" "openarch" {
  loadbalancer_id = azurerm_lb.openarch.id
  name            = "app-health-probe"
  port            = 80
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "openarch" {
  for_each  = var.lb_rule
  loadbalancer_id                = each.value.loadbalancer_id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  probe_id = each.value.probe_id
  backend_address_pool_ids = each.value.backend_address_pool_ids
}
