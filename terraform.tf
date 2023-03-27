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
  subscription_id     = "9d8f5b98-ffb7-4255-a0d1-7b3faaf6424a"
}

locals {
  location       = "canadacentral"
  resource_group = "SonarQube-RG"
  subscription_id     = "9d8f5b98-ffb7-4255-a0d1-7b3faaf6424a"
  vnet_resource_group = "lsPccCoreServicesCommon-rg"
  vm1_prefix          = "SonarQube-Instance"
  # vm2_prefix          = "linux2"
  vnet_name           = "lsPccCoreServicesCommon-vnet"
  vm_subnet_name      = "gitlab"
  vm_size             = "Standard D2as_v5"
  vm_admin_username   = "azureuser"
 
}

resource "azurerm_resource_group" "new-rg" {
  name     = local.resource_group
  location = local.location
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
  }
}

#  Create (and display) an SSH key
resource "tls_private_key" "first_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "first-vm" {
  name                            = "${local.vm1_prefix}-vm"
  location                        = local.location
  resource_group_name             = local.resource_group
  network_interface_ids           = [azurerm_network_interface.first-vm-nic.id]
  size                            = local.vm_size
  admin_username                  = local.vm_admin_username
  disable_password_authentication = true
  zone                            =  "1"

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
    name                 = "${local.vm1_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "64"
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

output "tls_private_key" {
  value     = tls_private_key.first_vm_ssh.private_key_pem
  sensitive = true
}
