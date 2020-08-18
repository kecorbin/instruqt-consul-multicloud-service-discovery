
// https://github.com/terraform-providers/terraform-provider-azurerm/issues/764
data "azurerm_public_ip" "gateway" {
  name                = "${azurerm_virtual_network_gateway.aws.name}_public_ip"
  resource_group_name = azurerm_resource_group.instruqt.name
}

resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = data.azurerm_public_ip.gateway.ip_address
  type       = "ipsec.1"
  tags = {
    Name = "azure-vpn-customer-gateway"
  }
}

resource "aws_vpn_connection" "azure" {
  vpn_gateway_id      = module.vpc.vgw_id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "azure-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "azure" {
  
  vpn_connection_id      = aws_vpn_connection.azure.id
  destination_cidr_block = module.vnet.vnet_address_space[0]
}

resource "aws_vpn_gateway_route_propagation" "public" {
  route_table_id = module.vpc.public_route_table_ids[0]
  vpn_gateway_id = module.vpc.vgw_id
}

resource "aws_vpn_gateway_route_propagation" "private" {
  route_table_id = module.vpc.private_route_table_ids[0]
  vpn_gateway_id = module.vpc.vgw_id
}

resource "azurerm_subnet" "gateway" {
  # azure requires this to be named 'GatewaySubnet'
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.instruqt.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes       = ["10.2.3.0/24"]
}

resource "azurerm_public_ip" "gateway" {
  name                = "aws-vpn-gateway_public_ip"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "aws" {
  name                = "aws-vpn-gateway"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  sku           = "VpnGw1"
  active_active = false
  enable_bgp    = false

  ip_configuration {
    subnet_id            = azurerm_subnet.gateway.id
    public_ip_address_id = azurerm_public_ip.gateway.id
  }
}

resource "azurerm_local_network_gateway" "aws1" {
  name                = "aws-gateway-1"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location

  gateway_address = aws_vpn_connection.azure.tunnel1_address
  address_space   = [module.vpc.vpc_cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "aws1" {
  name                = "aws-connection-1"
  resource_group_name = azurerm_resource_group.instruqt.name
  location            = azurerm_resource_group.instruqt.location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.aws.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws1.id
  shared_key                 = aws_vpn_connection.azure.tunnel1_preshared_key
}