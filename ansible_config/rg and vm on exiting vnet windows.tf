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
  subscription_id     = "ca61491a-d208-4a2a-a5a3-8ce5a3d960e0"
}

locals {
  location       = "westeurope"
  resource_group = "new-rg"
  subscription_id     = "ca61491a-d208-4a2a-a5a3-8ce5a3d960e0"
  vnet_resource_group = "d-avd-rg"
  vm1_prefix          = "win"
  vnet_name           = "d-avd-vNet"
  vm_subnet_name      = "d-avd-hpSubnet"
  vm_size             = "Standard_D2as_v4"
  vm_admin_username   = "azureuser"
  vm_admin_password   = "cde3CDE#vfr4VFR$"
 
}

resource "azurerm_resource_group" "new-rg" {
  name     = local.resource_group
  location = local.location
}

/* # Create Network Security Group and rule
resource "azurerm_network_security_group" "first-nsg" {
  name                = "${local.vm1_prefix}-nsg"
  location            = local.location
  resource_group_name = local.resource_group

  security_rule {
    name                       = "rdp"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "first-one-subnet-nsg-association" {
  subnet_id                 = "/subscriptions/${local.subscription_id}/resourceGroups/${local.vnet_resource_group}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.vm_subnet_name}"
  network_security_group_id = azurerm_network_security_group.first-nsg.id
}
*/

resource "azurerm_public_ip" "first-vm-pip" {
  name                = "${local.vm1_prefix}-pip"
  location            = local.location
  resource_group_name = local.resource_group
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.new-rg]
}

resource "azurerm_network_interface" "first-vm-nic" {
  name                 = "${local.vm1_prefix}-nic"
  location             = local.location
  resource_group_name  = local.resource_group
  enable_ip_forwarding = false
  depends_on = [azurerm_resource_group.new-rg]
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.vm1_prefix}-config"
    subnet_id                     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.vnet_resource_group}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/${local.vm_subnet_name}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.first-vm-pip.id
  }
}

resource "azurerm_windows_virtual_machine" "first-vm" {
  name                  = "${local.vm1_prefix}-vm"
  location              = local.location
  resource_group_name   = local.resource_group
  network_interface_ids = [azurerm_network_interface.first-vm-nic.id]
  size                  = local.vm_size
  admin_username        = local.vm_admin_username
  admin_password        = local.vm_admin_password

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  os_disk {
    name                 = "${local.vm1_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


}

resource "azurerm_virtual_machine_extension" "first-vm-ext" {
  name                 = "${local.vm1_prefix}-vm"
  virtual_machine_id   = azurerm_windows_virtual_machine.first-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"


    protected_settings = <<PROTECTED_SETTINGS
          {
          "commandToExecute": "powershell.exe -Command \"./new.ps1; exit 0;\""
          }
            PROTECTED_SETTINGS
  settings = <<SETTINGS
              {
        "fileUris": [
          "https://raw.githubusercontent.com/rs-pk/ansiblesonar/main/new.ps1"
        ]
    }
SETTINGS
}
