terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.prefix
  location = var.location
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-PublicIp1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    udacity-dws = "Production"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    udacity-dws = "Production"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  count = var.vm_num
  name                = "${var.prefix}-nic-${count.index+1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    udacity-dws = "Production"
  }
}

resource "azurerm_lb" "main" {
  
  name                = "${var.prefix}-LoadBalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-frontendIpConfiguration"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    udacity-dws = "Production"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id = azurerm_lb.main.id
  name            = "${var.prefix}-BackEndAddressPool"
}


resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.vm_num
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}



resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-network-security_group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    udacity-dws = var.securityTag
  }
}

resource "azurerm_network_security_rule" "rule1"{
    name                       = "${var.securityGroup}-allowVM"
    description = "Allow access to other VMs on the subnet."
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    destination_address_prefix =  "VirtualNetwork"
    source_address_prefix      = "VirtualNetwork"
    destination_application_security_group_ids = []
    source_application_security_group_ids = []
    resource_group_name = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "rule2"{
    name                       = "${var.securityGroup}-denyDirectAccess"
    description = "Deny direct access from the internet."
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    destination_address_prefix =  "VirtualNetwork"
    source_address_prefix      = "VirtualNetwork"
    destination_application_security_group_ids = []
    source_application_security_group_ids = []
    resource_group_name = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}


resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-VMset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    udacity-dws = "Production"
  }
}

resource "azurerm_managed_disk" "main" {
  count = var.managed_disks_num
  name                 = "${count.index + 1 }-ManagedDisks"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    udacity-dws = "staging"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count = var.vm_num
  name                            = "${ count.index+ 1}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = var.username
  admin_password                  = var.password

  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  availability_set_id = azurerm_availability_set.main.id

  source_image_id = var.imageId

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    udacity-dws = "vm"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  count = var.vm_num 
  managed_disk_id    = azurerm_managed_disk.main[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[ count.index].id
  lun                = "10"
  caching            = "ReadWrite"

}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  count = var.vm_num 
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "1700"
  timezone              = "Eastern Standard Time"

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.example.com"
  }

  tags = {
    udacity-dws = "auto-shutdown"
  }
}
