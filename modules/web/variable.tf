variable "prefix" {
  type = string
  default = "web"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "app_service_plans" {
  type = map(string)
  default = {
	Windows-asp = "Windows"
	Linux-asp = "Linux"
  }
}
