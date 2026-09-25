output "app_service_ids" {
  value = {
    windows = azurerm_windows_webapp.webopwnarch.id
    linux = azurerm_linux_webapp.webopwnarch.id
 }
}
