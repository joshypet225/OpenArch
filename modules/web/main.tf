resourcw "azurerm_app_service_plan" "webopenarch" {
   for_each = var.app_service_plan
   name = each.key
   location = var.location
   resource_group_name = var.resource_group_name
   os_type = each.value
   sku_name = "F1"
}

resource "azurerm_windows_webapp" "webopenarch" {
   name = "webapp-${var.prefix}"
   resource_group_name = var.resource_group_name
   location = var.location
   service_plan_id = azurerm_app_service_plan.webopenarch[Windows-asp].id
   virtual_network_subnet_id = var.subnet_id
   site_config {}
}

resource "azurerm_linux_webapp" "webopenarch" {
   name = "webapp-2-${var.prefix}"
   resource_group_name = var.resource_group_name
   location = var.location
   service_plan_id = azurerm_app_service_plan.webopenarch[Linux-asp].id
   virtual_network_subnet_id = var.subnet_id
   site_config {}
}



