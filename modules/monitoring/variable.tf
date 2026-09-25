variable "resource_group_name" {
	type = string
}

variable "location" {
	type = string
}

variable "application_gateway_id" {
	type = string
}

variable "app_service_ids" {
	type = map(string)
}

variable "vmss_ids" {
	type = map(string)
}

variable "sql_database_id" {
	type = string
}

variable "nosql_id" {
	type = string
}

variable "prefix" {
	type = string
	default = "openarch"
}

variable "email" {
	type = string
}
