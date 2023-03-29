# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "testimg"

    workspaces {
      name = "learn-terraform-github-actions-azure"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "fuat-terraform-experiment"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-vnet"
  address_space       = ["172.16.0.0/22"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnetterra"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                = "publicip1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "terraform-experiment"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1ls"
  admin_username                  = "fuatu"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "fuatu"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdOgHn70smnYAD1ceyyyItf3oQ+zyZCh2wy/OmnrBYbpEc2a44dT1qKPQAFyDNDxa777WWXlWCpLEhBHhRBvOAjRF434JbP1iUsJyOBDav1OuGVgFxfOcBwaHdcHd9r2WKssqI/b4tnrOgh3bFMkKSN5k9BxmRfiS90w2qW5cOWybWjNq7+rw3nihI9rIFHNnQ5BCd1+oFHmlyanhW5fHne6WFlPCQl9HmLiiN9luwQRGLIgJDYusuQ21ujkhU5z1XGEoVV5BD0+Hq1mK2XFbiAapebuyeaQH0/VCmophdL4I6EfLE3W5eXfT/kYEblJ9/RSQawVY1qA9eUMuF3Jk/ fuatulugay@Fuats-MacBook-Pro.local"
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name                 = "osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202303220"
  }

  computer_name = "terraformvm-testx"
}
