
module "app_module" {
  source                   = ".../modules/app"
  resource_group_name      = azurerm_resource_group.openarch.name
  location                 = azurerm_resource_group.openarch.location
  subnet_id                = module.network.subnet_details["app_subnet"].id
  backend_address_pool_ids = module.network.backend_address_pool_ids
}

module "web_module" {
  source              = ".../modules/web"
  resource_group_name = azurerm_resource_group.openarch.name
  location            = azurerm_resource_group.openarch.location
  subnet_id           = module.network.subnet_details["web_subnet"].id
}

module "db_module" {
  source              = ".../modules/db"
  resource_group_name = azurerm_resource_group.openarch.name
  location            = azurerm_resource_group.openarch.location
  subnet_id           = module.network.subnet_details["db_subnet"].id
}

module "monitoring_module" {
  source                 = ".../modules/monitoring"
  resource_group_name    = azurerm_resource_group.openarch.name
  location               = azurerm_resource_group.openarch.location
  application_gateway_id = module.network.application_gateway_id
  app_service_ids        = module.web.app_service_ids
  vmss_ids               = module.app.vmss_ids
  sql_database_id        = module.db.sql_database_id
  nosql_id               = module.db.nosql_id
}

