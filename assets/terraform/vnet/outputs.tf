output "resource_group_name" {
  value = azurerm_resource_group.instruqt.name
}

output "resource_group_location" {
  value = azurerm_resource_group.instruqt.location
}

output "vnet" {
  value = module.vnet.vnet_id
}

output "vnet_subnets" {
  value = module.vnet.vnet_subnets
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion.ip_address
}
