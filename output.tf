output "resource_group_details" {
  value = [
    azurerm_resource_group.openarch.name,
    azurerm_resource_group.openarch.id
  ]
}

output "location" {
  value = azurerm_resource_group.openarch.location
}
