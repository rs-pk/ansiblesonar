terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.28.0"
    }
  }
  required_version = ">= 1.1.9"
}

provider "azurerm" {
  features {}
}

locals {
  location            = "eastus"
  subscription_id     = "21bf6cf4-71f5-4ad4-b2b7-04f49a5f6d2b"
  resource_group      = "first1-vnet-rg"
  vm1_prefix           = "linux1"
  vm2_prefix           = "linux2"
  vnet_name           = "first-vnet"
  vm_subnet_name      = "oneSubnet"
  vm_size             = "Standard_B2s"
  vm_admin_username   = "adminuser"
  vm_admin_password   = "Password123!"
  bastion_subnet_name = "AzureBastionSubnet"

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "first-nsg" {
  name                = "${local.vm1_prefix}-nsg"
  location            = local.location
  resource_group_name = local.resource_group

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "first-one-subnet-nsg-association" {
  subnet_id                 = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.vm_subnet_name}"
  network_security_group_id = azurerm_network_security_group.first-nsg.id
}

resource "azurerm_public_ip" "first-vm-pip" {
  name                = "${local.vm1_prefix}-pip"
  location            = local.location
  resource_group_name = local.resource_group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "first-vm-nic" {
  name                 = "${local.vm1_prefix}-nic"
  location             = local.location
  resource_group_name  = local.resource_group
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "${local.vm1_prefix}-config"
    subnet_id                     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.vm_subnet_name}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.first-vm-pip.id

  }
}

# Create (and display) an SSH key
resource "tls_private_key" "first_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "first-vm" {
  name                  = "${local.vm1_prefix}-vm"
  location              = local.location
  resource_group_name   = local.resource_group
  network_interface_ids = [azurerm_network_interface.first-vm-nic.id]
  size                  = local.vm_size
  admin_username = local.vm_admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.vm_admin_username
    public_key = tls_private_key.first_vm_ssh.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202301140"
  }

  os_disk {
    name              = "${local.vm1_prefix}osdisk"
    caching           = "ReadWrite"
    storage_account_type= "Standard_LRS"
  }

}

resource "azurerm_virtual_machine_extension" "first-vm-ext" {
  name                 = "${local.vm1_prefix}-vm"
  virtual_machine_id   = azurerm_linux_virtual_machine.first-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
        {
        "fileUris": ["https://raw.githubusercontent.com/rs-pk/ansiblesonar/main/setup.sh"],
        "commandToExecute": "sh setup.sh"
    }
SETTINGS
}






resource "azurerm_public_ip" "second-vm-pip" {
  name                = "${local.vm2_prefix}-pip"
  location            = local.location
  resource_group_name = local.resource_group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "second-vm-nic" {
  name                 = "${local.vm2_prefix}-nic"
  location             = local.location
  resource_group_name  = local.resource_group
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "${local.vm2_prefix}-config"
    subnet_id                     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.vm_subnet_name}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.second-vm-pip.id

  }
}

# Create (and display) an SSH key
resource "tls_private_key" "second_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "second-vm" {
  name                  = "${local.vm2_prefix}-vm"
  location              = local.location
  resource_group_name   = local.resource_group
  network_interface_ids = [azurerm_network_interface.second-vm-nic.id]
  size                  = local.vm_size
  admin_username = local.vm_admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.vm_admin_username
    public_key = tls_private_key.second_vm_ssh.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202301140"
  }

  os_disk {
    name              = "${local.vm2_prefix}osdisk"
    caching           = "ReadWrite"
    storage_account_type= "Standard_LRS"
  }

}

resource "azurerm_virtual_machine_extension" "second-vm-ext" {
  name                 = "${local.vm2_prefix}-vm"
  virtual_machine_id   = azurerm_linux_virtual_machine.second-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
        {
        "fileUris": ["https://raw.githubusercontent.com/rs-pk/ansiblesonar/main/setup.sh"],
        "commandToExecute": "sh setup.sh"
    }
SETTINGS
}
