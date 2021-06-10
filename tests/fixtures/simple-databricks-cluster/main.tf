terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2"
    }
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.4"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    Owner       = "Ingenii"
    Environment = "Development"
    Description = "This resources belongs to automated testing environment."
  }
  random_string = lower(random_string.this.result)
}

resource "random_string" "this" {
  length  = 8
  number  = false
  special = false
}

resource "azurerm_resource_group" "this" {
  location = "UKSouth"
  name     = local.random_string
}

resource "azurerm_databricks_workspace" "this" {
  location = azurerm_resource_group.this.location
  tags     = local.tags

  name                        = local.random_string
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = "${local.random_string}-databricks"

  sku = "premium"
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.this.id
}

module "standard_cluster" {
  source = "../../../"

  name = "${local.random_string}-standard"
  tags = local.tags

  cluster_mode                 = "standard"
  cluster_runtime_version_type = "lts"

  worker_node_type_id = "Standard_F4s"
  driver_node_type_id = "Standard_F4s"


  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

module "single_node_cluster" {
  source = "../../../"

  name = "${local.random_string}-single-node"
  tags = local.tags

  cluster_mode                 = "single_node"
  cluster_runtime_version_type = "lts"

  worker_node_type_id = "Standard_F4s"

  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

module "high_concurrency_cluster" {
  source = "../../../"

  name = "${local.random_string}-high-concurrency"
  tags = local.tags

  cluster_mode                 = "high_concurrency"
  cluster_runtime_version_type = "latest"

  auto_termination_in_minutes = 30

  auto_scale_min_workers = 1
  auto_scale_max_workers = 4

  pypi_packages = [
    { name = "dbt", version = "0.19.1" }
  ]

  worker_node_type_id = "Standard_F4s"
  driver_node_type_id = "Standard_F4s"


  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

output "random_string" {
  value = local.random_string
}

output "expected_standard_name" {
  value = "${local.random_string}-standard"
}

output "actual_standard_name" {
  value = module.standard_cluster.cluster_name
}

output "expected_single_node_name" {
  value = "${local.random_string}-single-node"
}

output "actual_single_node_name" {
  value = module.single_node_cluster.cluster_name
}

output "expected_high_concurrency_name" {
  value = "${local.random_string}-high-concurrency"
}

output "actual_high_concurrency_name" {
  value = module.high_concurrency_cluster.cluster_name
}
