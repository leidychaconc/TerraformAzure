provider "azurerm" {
  features {}

  subscription_id = var.subscriptionId
  client_id       = var.appId
  client_secret   = var.appId_password
  tenant_id       = var.tenantId
}

resource "azurerm_resource_group" "default" {
  name     = "azrgeuappd01"
  location = "East US"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_container_registry" "default" {
  name                     = "azcreuappd01"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "azkseuappd01"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "dns-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }
  
  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Development"
  }
}

data "azurerm_container_registry" "acr_name" {
  name = azurerm_container_registry.default.name
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_role_assignment" "aks_to_acr_role" {
  scope                = data.azurerm_container_registry.acr_name.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
}

resource "azurerm_postgresql_server" "default" {
  name                = "azdbpgodoo"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.pg_administrator_login
  administrator_login_password = var.pg_administrator_login_password
  version                      = "10"
  ssl_enforcement_enabled      = false
#  allow_azure_services_access  = true
}

resource "azurerm_postgresql_firewall_rule" "default" {
  name                = "access"
  resource_group_name = azurerm_resource_group.default.name
  server_name         = azurerm_postgresql_server.default.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
