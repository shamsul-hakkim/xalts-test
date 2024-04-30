terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.101.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test-rg" {
  name     = "test-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test-vn" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
}

resource "azurerm_subnet" "test-subnet" {
  name                 = "test-subnet"
  resource_group_name  = azurerm_resource_group.test-rg.name
  virtual_network_name = azurerm_virtual_network.test-vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "test-nsg" {
  name                = "test-nsg"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  security_rule {
    name                       = "app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "5000"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test-ni.id
  network_security_group_id = azurerm_network_security_group.test-nsg.id
}

resource "azurerm_public_ip" "test-pub-ip" {
  name                = "test-pub-ip"
  resource_group_name = azurerm_resource_group.test-rg.name
  location            = azurerm_resource_group.test-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "test-ni" {
  name                = "test-nic"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test-pub-ip.id
  }
}


resource "azurerm_linux_virtual_machine" "test-vm" {
  name                = "test-vm"
  resource_group_name = azurerm_resource_group.test-rg.name
  location            = azurerm_resource_group.test-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Admin_admin@123"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.test-ni.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("keys/test.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
