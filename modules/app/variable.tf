variable "resource_group_name" {
   type = string
}

variable "location" {
   type = string
}

variable "subnet_id" {
   type = string
}

variable "prefix" {
   type = string
   default = "web"
}

variable "backend_address_pool_ids" {
   type = list(string)
}
