# Generate all resources supported by ip2cr

resource "azurerm_resource_group" "ip-2-cloudresource" {
  name     = "ip-2-cloudresource"
  location = "East US"
}

## Networking
### Virtual Networks
variable "virtual_net_cidr" {
  default = "192.168.200.0/26"
}

resource "azurerm_virtual_network" "ip2cr-virtual-net" {
  name                = "ip2cr-virtual-net"
  address_space       = [var.virtual_net_cidr]
  location            = azurerm_resource_group.ip-2-cloudresource.location
  resource_group_name = azurerm_resource_group.ip-2-cloudresource.name
}

### Virtual Subnets
variable "num_subnets" {
  default = 3
}

locals {
    ipv4_subnets = cidrsubnets(azurerm_virtual_network.ip2cr-virtual-net.address_space[0], [for i in range(var.num_subnets) : "2"]...)
    # we can't use cidrsubnets() for IPv6 since it doesn't support increasing the mask
}

resource "azurerm_subnet" "ip2cr-subnet-1" {
  name                 = "ip2cr-subnet-1"
  resource_group_name  = azurerm_resource_group.ip-2-cloudresource.name
  virtual_network_name = azurerm_virtual_network.ip2cr-virtual-net.name
  address_prefixes     = [local.ipv4_subnets[0]]
}

resource "azurerm_subnet" "ip2cr-subnet-2" {
  name                 = "ip2cr-subnet-2"
  resource_group_name  = azurerm_resource_group.ip-2-cloudresource.name
  virtual_network_name = azurerm_virtual_network.ip2cr-virtual-net.name
  address_prefixes     = [local.ipv4_subnets[1]]
}

resource "azurerm_subnet" "ip2cr-subnet-3" {
  name                 = "ip2cr-subnet-3"
  resource_group_name  = azurerm_resource_group.ip-2-cloudresource.name
  virtual_network_name = azurerm_virtual_network.ip2cr-virtual-net.name
  address_prefixes     = [local.ipv4_subnets[2]]
}

### IP Addresses
resource "azurerm_public_ip" "ip2cr-public-ip-vm" {
  name                = "ip2cr-public-ip-vm"
  location            = azurerm_resource_group.ip-2-cloudresource.location
  resource_group_name = azurerm_resource_group.ip-2-cloudresource.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "ip2cr-public-ip-lb" {
  name                = "ip2cr-public-ip-lb"
  location            = azurerm_resource_group.ip-2-cloudresource.location
  resource_group_name = azurerm_resource_group.ip-2-cloudresource.name
  allocation_method   = "Static"
}

### NICs
resource "azurerm_network_interface" "ip2cr-vm-nic-1" {
  name                = "ip2cr-vm-nic-1"
  location            = azurerm_resource_group.ip-2-cloudresource.location
  resource_group_name = azurerm_resource_group.ip-2-cloudresource.name

  ip_configuration {
    name                          = "ip2cr-subnet-1"
    subnet_id                     = azurerm_subnet.ip2cr-subnet-1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "ip2cr-vm-nic-2" {
  name                = "ip2cr-vm-nic-2"
  location            = azurerm_resource_group.ip-2-cloudresource.location
  resource_group_name = azurerm_resource_group.ip-2-cloudresource.name

  ip_configuration {
    name                          = "ip2cr-subnet-1"
    subnet_id                     = azurerm_subnet.ip2cr-subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip2cr-public-ip-vm.id
  }
}

## Compute
### VMs
resource "azurerm_linux_virtual_machine" "ip2cr-vm" {
  name                  = "ip2cr-testing"
  resource_group_name   = azurerm_resource_group.ip-2-cloudresource.name
  location              = azurerm_resource_group.ip-2-cloudresource.location
  size                  = "Standard_B2als_v2"
  admin_username        = "ip2cradmin"
  network_interface_ids = [
    azurerm_network_interface.ip2cr-vm-nic-1.id,
    azurerm_network_interface.ip2cr-vm-nic-2.id
  ]

  admin_ssh_key {
    username   = "ip2cradmin"
    public_key = file(var.ssh_key_file)
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

output "ip2cr-vm-metadata" {
  value = [
    azurerm_linux_virtual_machine.ip2cr-vm.id,
    azurerm_linux_virtual_machine.ip2cr-vm.name,
    azurerm_linux_virtual_machine.ip2cr-vm.public_ip_address
  ]
}

## Load Balancers
resource "azurerm_lb" "ip2cr-lb" {
  name                = "ip2cr-lb"
  location            = azurerm_resource_group.ip-2-cloudresource.location
  resource_group_name = azurerm_resource_group.ip-2-cloudresource.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ip2cr-public-ip-lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "ip2cr-lb-backend-address-pool" {
  name                = "ip2cr-lb-backend"
  loadbalancer_id     = azurerm_lb.ip2cr-lb.id
}

resource "azurerm_lb_probe" "ip2cr-lb-probe" {
  name                = "tcp-probe"
  protocol            = "Tcp"
  port                = 22
  loadbalancer_id     = azurerm_lb.ip2cr-lb.id
}

resource "azurerm_lb_rule" "ip2cr-lb-rule-1" {
  name                           = "ip2cr-lb-rule-1"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.ip2cr-lb.frontend_ip_configuration[0].name
  loadbalancer_id                = azurerm_lb.ip2cr-lb.id
  probe_id                       = azurerm_lb_probe.ip2cr-lb-probe.id
}

resource "azurerm_network_interface_backend_address_pool_association" "ip2cr-lb-nic-association" {
  network_interface_id    = azurerm_network_interface.ip2cr-vm-nic-1.id
  ip_configuration_name   = azurerm_network_interface.ip2cr-vm-nic-1.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ip2cr-lb-backend-address-pool.id
}

output "ip2cr-lb-metadata" {
  value = [
    azurerm_lb.ip2cr-lb.id,
    azurerm_public_ip.ip2cr-public-ip-lb.ip_address
  ]
}