# Generate random string for unique compute instance name
resource "random_string" "ci_prefix" {
  length  = 8
  upper   = false
  special = false
  numeric = false
}

# Compute instance
resource "azurerm_machine_learning_compute_instance" "compute_instance" {
  name                          = "${random_string.ci_prefix.result}instance"
  location                      = azurerm_resource_group.default.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.default.id
  virtual_machine_size          = "STANDARD_DS2_V2"
  subnet_resource_id            = azurerm_subnet.snet-training.id

  depends_on = [
    azurerm_private_endpoint.mlw_ple
  ]
}

# Compute cluster
resource "azurerm_machine_learning_compute_cluster" "compute" {
  name                          = "cpu-cluster"
  location                      = azurerm_resource_group.default.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.default.id
  vm_priority                   = "Dedicated"
  vm_size                       = "STANDARD_DS2_V2"
  subnet_resource_id            = azurerm_subnet.snet-training.id

  identity {
    type = "SystemAssigned"
  }

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 3
    scale_down_nodes_after_idle_duration = "PT15M" # 15 minutes
  }

}