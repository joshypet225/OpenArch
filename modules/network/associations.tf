resource "azurerm_subnet_network_security_group_association" "openarch" {
   for_each = var.subnet_nsg_map
   subnet_id = azurerm_subnet.openarch[each.key].id
   network_security_group_id = azurerm_network_security_group.openarch[each.value].id
}
