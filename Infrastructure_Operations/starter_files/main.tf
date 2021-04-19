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
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
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
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "${var.prefix}-BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.main.id
  ip_configuration_name   = "${var.prefix}-networkBackendAssociation"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}




# todo ??????????
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-network-security_group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule =[{
    name                       = "${var.securityGroup}-allowVM"
    description = "Allow access to other VMs on the subnet."
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  },
    {
    name                       = "${var.securityGroup}-denyDirectAccess"
    description = "Deny direct access from the internet."
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }]

  tags = {
    environment = "${var.securityTag}"
  }
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-VMset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
