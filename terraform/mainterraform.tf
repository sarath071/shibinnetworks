# Terraform provider for Azure
provider "azurerm" {
  features {}
}

# Define Variables with new names
variable "azure_region" {
  default = "East US"
}

variable "resource_group" {
  default = "app-infrastructure-rg"
}

variable "virtual_machine" {
  default = "ubuntu-server"
}

variable "admin_user" {
  default = "ubuntuadmin"
}

# SSH Key Pair Generation for VM Access
resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create a Resource Group in Azure
resource "azurerm_resource_group" "main_rg" {
  name     = var.resource_group
  location = var.azure_region
}

# Define Virtual Network Configuration
resource "azurerm_virtual_network" "app_vnet" {
  name                = "${var.virtual_machine}-vnet"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = ["10.0.0.0/22"]
}

# Create a Subnet for the Virtual Machine
resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.virtual_machine}-subnet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Allocate Public IP for the VM
resource "azurerm_public_ip" "app_public_ip" {
  name                = "${var.virtual_machine}-public-ip"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

# Create Network Interface for the VM with Public IP
resource "azurerm_network_interface" "app_nic" {
  name                = "${var.virtual_machine}-nic"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  ip_configuration {
    name                          = "primary-config"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_public_ip.id
  }
}

# Define Network Security Group (NSG) for controlling inbound/outbound traffic
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "app_nsg_association" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# Create an Azure Linux Virtual Machine using Ubuntu Server
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                = var.virtual_machine
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  size                = "Standard_B1ms"

  admin_username = var.admin_user

  # SSH authentication using the generated SSH public key
  admin_ssh_key {
    username   = var.admin_user
    public_key = tls_private_key.vm_ssh_key.public_key_openssh
  }

  network_interface_ids = [azurerm_network_interface.app_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}

# Outputs to Display Important Information
output "vm_public_ip" {
  value = azurerm_public_ip.app_public_ip.ip_address
}

output "private_key_path" {
  value     = tls_private_key.vm_ssh_key.private_key_pem
  sensitive = true
}
