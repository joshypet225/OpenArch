output "virtual_network_details" {
  value = {[
    azurerm_virtual_network.openarch.name,
    azurerm_virtual_network.openarch.id
  ]}
}

output "subnet_details" {
  value = {
    for k, s in azurerm_subnet.openarch: k => { 
    name = s.name
    id = s.id
  }
 }
}

output "backend_address_pool_ids" {
  value = {
	for k, b in azurerm_lb_backend_address_pool.openarch: k => b.id
 }
}

output "nsg_details" {
  value = {[
    for k, n in azurerm_network_security_group.openarch: k => n.name,
    for k, n in azurerm_network_security_group.openarch: k => n.id
  ]}
}

output "application_gateway_id" {
   value = azurerm_application_gateway.openarch.id
}
