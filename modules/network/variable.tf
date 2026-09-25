variable "subnets" {
  type = map(list(string))
  default = {
   web_subnet = ["10.0.1.0/24"]
   app_subnet = ["10.0.2.0/24"]
   db_subnet = ["10.0.3.0/24"]
   AzureBastionSubnet = ["10.0.4.0/24"]
   gatewaySubnet = ["10.0.5.0/24"]
  }
}

variable "nsg" {
  type = map(any)
  default = {
    web_nsg = {
        security_rule [{
              name = "AllowHTTP"
              priority = 100
              direction = "Inbound"
              access = "Allow"
              protocol = "Tcp"
              source_port_range = "*"
              destination_port_range = "80"
              source_address_prefix = "*"
              destination_address_prefix = "*"
        },
        {
              name = "AllowHTTPS"
              priority = 110
              direction = "Inbound"
              access = "Allow"
              protocol = "Tcp"
              source_port_range = "*"
              destination_port_range = "443"
              source_address_prefix = "*"
              destination_address_prefix = "*"
        }
       ]
     }

   app_nsg ={
      security_rule {
              name = "AllowWebInbound"
              priority = 100
              direction = "Inbound"
              access = "Allow"
              protocol = "*"
              source_port_range = "*"
              destination_port_range = "80"
              source_address_prefix = "10.0.1.0/24"
              destination_address_prefix = "*"
        }
     }

   db_nsg ={
      security_rule {
              name = "AllowApp"
              priority = 100
              direction = "Inbound"
              access = "Allow"
              protocol = "Tcp"
              source_port_range = "*"
              destination_port_range = "*"
              source_address_prefix = "10.0.2.0/24"
              destination_address_prefix = "*"
      }
   }
 }

variable "subnet_nsg_map" {
  type = map(any)
  default = {
    web_subnet = web_nsg
    app_subnet = app_nsg
    db-subnet = db_nsg
  }
}

variable "resource_group_name" {
   type = string
}

varible "location" {
   type = string
}

variable "prefix" {
   type = string
}

variable "public_ip" {
   type = list(string)
   default = ["bastion", "gateway"]
}

variable "lb_backend_address_pool" {
   type = list(strong)
   default = ["WindowsVMSS", "LinuxVMSS"]
}

variable "lb_rule" {
   type = map(object({
		  loadbalancer_id                = string
		  name                           = string
		  protocol                       = string
		  frontend_port                  = number
		  backend_port                   = number
		  frontend_ip_configuration_name = string
		  probe_id = string
		  backend_address_pool_ids = string
		}))
   default = {
      WindowsRule = {
                  loadbalancer_id                = azurerm_lb.openarch.id
                  name                           = "RouteWindowsRule"
                  protocol                       = "Tcp"
                  frontend_port                  = 8080
                  backend_port                   = 80
                  frontend_ip_configuration_name = "InternalAppFrontend"
                  probe_id = azurerm_lb_probe.openarch.id
                  backend_address_pool_ids = azurerm_lb_backend_address_pool.openarch["WindowsVMS>
        }
      LinuxRule = {
		  loadbalancer_id                = azurerm_lb.openarch.id
                  name                           = "RouteToLinuxRule"
                  protocol                       = "Tcp"
                  frontend_port                  = 8081
                  backend_port                   = 80
                  frontend_ip_configuration_name = "InternalAppFrontend"
                  probe_id = azurerm_lb_probe.openarch.id
                  backend_address_pool_ids = azurerm_lb_backend_address_pool.openarch["LinuxVMSS"].id
	}
    }     
}
