output "vmss_ids" {
   value = {
	windows = azurerm_windows_virtual_machine_scale_set
	linux = azurerm_linux_virtual_machine_scale_set
 }
}
