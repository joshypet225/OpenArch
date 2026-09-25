variable "client_id" {
  type        = string
  description = "Client ID"
  sensitive   = true
}

variable "client_secret" {
  type        = string
  description = "Client secret"
  sensitive   = true
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID"
  sensitive   = true
}

variable "prefix" {
  default = "openarch"
  type    = String
}

variable "location" {
  default = "eastus2"
  type    = String
}

