resource "azurerm_linux_virtual_machine_scale_set" "openapp" {
  name                = "${var.prefix}-vmss"
  resource_group_name = var.resource_group_name
  location            = var_location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_ed25519")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "linux-web"
    primary = true

    ip_configuration {
      name      = "web-subnet1"
      primary   = true
      subnet_id = var.subnet_id
      load_balancer_backend_address_pool_ids= [
	var.backend_address_pool_ids[1]
     ]
    }
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "openweb" {
  name                 = "${var.prefix}-vmssl"
  resource_group_name  = var.resource_group_name
  location             = var.location
  sku                  = "Standard_F2"
  instances            = 1
  admin_password       = "P@55w0rd1234!"
  admin_username       = "adminuser"
  computer_name_prefix = "vm-"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "windows-web"
    primary = true

    ip_configuration {
      name      = "web-subnet"
      primary   = true
      subnet_id = var.subnet_id
      load_balancer_backend_address_pool_ids= [
        var.backend_address_pool_ids[0]
     ]
    }
  }
}
