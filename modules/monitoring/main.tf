resource "azurerm_log_analytics_workspace" "openarch" {
  name                = "${var.prefix}-la"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

locals {
  monitored_resources = merged({   
   application_gateway = {
	resource_id = var.application_gateway_id
	logs = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
   },
   sql_database = {
	resource_id = var.sql_database_id
	logs = ["SQLInsights", "AutomaticTuning", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics", "Errors"]
   },
   nosql = { 
	resource_id = var.nosql_id
	logs = ["DataPlaneRequests", "MongoRequests", "QueryRuntimeStatistics"]
   },
   {
   for k, a in var.app_service_ids: "${k}-app_service" => {
	resource_id = a
	logs = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs", "AppServiceAuditLogs"]
	}
   },
   {
   for k, v in var.vmss_id: "vmss-${k}" => {
	resource_id = v
        logs = []
	}
  })
}

resource "azurerm_monitor_diagnostic_setting" "openarch" {
  for_each = local.monitored_resources
  name                       = "${each.key}-dlag"
  target_resource_id         = each.value.resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sui.id

  metric {
      category = "AllMetrics"
      enabled  = true
  }
  dynamic "enabled_log" {
    for_each = each.value.logs
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_monitor_action_group" "openarch" {
  name                = "CriticalAlertsAction"
  resource_group_name = var.resource_group_name
  short_name          = "openarch-alert"

  email_receiver {
    name          = "sendtoadmin"
    email_address = var.email
  }
}

resource "azurerm_monitor_metric_alert" "openarch" {
  for_each            = var.vmss_ids 
  name                = "${var.prefix}-metric-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value]
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.openarch.id
  }
}
