output "vpc" {
  value = module.vpc.vpc_id
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vgw_id" {
  value = module.vpc.vgw_id
}


output "resource_group_name" {
  value = azurerm_resource_group.instruqt.name
}

output "resource_group_location" {
  value = azurerm_resource_group.instruqt.location
}

output "vnet" {
  value = module.vnet.vnet_id
}

output "vnet_address_space" {
  value = module.vnet.vnet_address_space
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "location" {
  value = azurerm_resource_group.instruqt.location
}
output "vnet_subnets" {
  value = module.vnet.vnet_subnets
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

output "aws_bastion_ip" {
  value = aws_instance.bastion-shared-svcs.public_ip
}
