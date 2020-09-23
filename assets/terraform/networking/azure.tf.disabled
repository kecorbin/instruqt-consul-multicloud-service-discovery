provider "azurerm" {
  version = "=2.13.0"
  features {}
}

resource "random_string" "participant" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "azurerm_resource_group" "instruqt" {
  name     = "csl-land-demo-team2-${random_string.participant.result}"
  location = "East US"
}

module "vnet" {
  source              = "Azure/network/azurerm"
  vnet_name           = "vnet"
  resource_group_name = azurerm_resource_group.instruqt.name
  address_space       = "10.2.0.0/16"
  subnet_prefixes     = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  subnet_names        = ["subnet0", "subnet1", "subnet2"]

  tags = {
    owner = "instruqt@hashicorp.com"
  }
}


resource "azurerm_public_ip" "bastion" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "bastion" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_virtual_machine" "bastion" {
  name                  = "bastion-vm"
  location              = azurerm_resource_group.instruqt.location
  resource_group_name   = azurerm_resource_group.instruqt.name
  network_interface_ids = [azurerm_network_interface.bastion.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "bastion-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "bastion"
    admin_username = "azure-user"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azure-user/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    environment = "staging"
  }
}

resource "azurerm_network_security_group" "bastion" {
  name                = "bastion-nsg"
  location            = azurerm_resource_group.instruqt.location
  resource_group_name = azurerm_resource_group.instruqt.name

  # Allow SSH traffic in from Internet to public subnet.
  security_rule {
    name                       = "allow-ssh-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-10nets"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }  
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

