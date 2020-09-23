provider "azurerm" {
  version = "=2.0.0"
  features {}
}

variable "remote_state" {
  default = "/root/terraform"
}

data "terraform_remote_state" "vnet" {
  backend = "local"

  config = {
    path = "${var.remote_state}/networking/terraform.tfstate"
  }
}

resource "azurerm_kubernetes_cluster" "frontend" {
  name                = "frontend-aks"
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  location            = data.terraform_remote_state.vnet.outputs.resource_group_location
  dns_prefix          = "frontend"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = data.terraform_remote_state.vnet.outputs.vnet_subnets[0]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  service_principal {
    client_id     = "msi"
    client_secret = "msi"
  }

  tags = {
    Environment = "Production"
  }
}


output "frontend_client_certificate" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.client_certificate
}

output "frontend_kube_config" {
  value = azurerm_kubernetes_cluster.frontend.kube_config_raw
}

output "frontend_cluster_ca" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.cluster_ca_certificate
}

output "frontend_cluster_host" {
  value = azurerm_kubernetes_cluster.frontend.kube_config.0.host
}

