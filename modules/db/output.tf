output "sql_database_id" {
	value = azurerm_mssql_database.openarch.id
}

output "nosql_id" {
	value = azurerm_cosmosdb_mongo_database.openarch.id
}
