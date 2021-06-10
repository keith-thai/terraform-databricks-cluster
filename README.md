## terraform-databricks-cluster

[![Maintainer](https://img.shields.io/badge/maintainer%20-ingenii-orange?style=flat)](https://ingenii.dev/)
[![License](https://img.shields.io/badge/license%20-MPL2.0-orange?style=flat)](https://github.com/ingenii-solutions/terraform-databricks-cluster/blob/main/LICENSE)
[![Contributing](https://img.shields.io/badge/howto%20-contribute-blue?style=flat)](https://github.com/ingenii-solutions/terraform-databricks-cluster/blob/main/CONTRIBUTING.md)
[![Static Code Analysis](https://github.com/ingenii-solutions/terraform-databricks-cluster/actions/workflows/static-code-analysis.yml/badge.svg?branch=main)](https://github.com/ingenii-solutions/terraform-databricks-cluster/actions/workflows/static-code-analysis.yml)
[![Unit Tests](https://github.com/ingenii-solutions/terraform-databricks-cluster/actions/workflows/unit-tests.yml/badge.svg?branch=main)](https://github.com/ingenii-solutions/terraform-databricks-cluster/actions/workflows/unit-tests.yml)

## Description

This module can be used to create and manage Databricks clusters.

## Requirements

<!--- <<ii-tf-requirements-begin>> -->
| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | ~> 0.3 |
<!--- <<ii-tf-requirements-end>> -->

## Example Usage

### Standard Cluster (Azure)

```terraform
resource "azurerm_resource_group" "this" {
  location = "UKSouth"
  name     = "IngeniiSolutions"
}

resource "azurerm_databricks_workspace" "this" {
  location = azurerm_resource_group.this.location
  tags     = { Owner = "Developer" }

  name                        = "example"
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = "${azurerm_resource_group.this.name}-databricks"

  sku = "trial"
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.this.id
}

module "standard_cluster" {
  source  = "ingenii-solutions/cluster/databricks"
  version = "x.x.x"

  name = "standard-cluster"
  tags = { Owner = "Developer" }

  cluster_mode                 = "standard"
  cluster_runtime_version_type = "lts"

  worker_node_type_id = "Standard_F4s"
  driver_node_type_id = "Standard_F4s"


  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

```

### Single Node Cluster (Azure)

```terraform
resource "azurerm_resource_group" "this" {
  location = "UKSouth"
  name     = "IngeniiSolutions"
}

resource "azurerm_databricks_workspace" "this" {
  location = azurerm_resource_group.this.location
  tags     = { Owner = "Developer" }

  name                        = "example"
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = "${azurerm_resource_group.this.name}-databricks"

  sku = "trial"
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.this.id
}

module "single_node_cluster" {
  source  = "ingenii-solutions/cluster/databricks"
  version = "x.x.x"

  name = "single-node-cluster"
  tags = { Owner = "Developer" }

  cluster_mode                 = "single_node"
  cluster_runtime_version_type = "latest"

  worker_node_type_id = "Standard_F4s"

  depends_on = [
    azurerm_databricks_workspace.this
  ]
}
```

### High Concurrency Cluster (Azure)

```terraform
resource "azurerm_resource_group" "this" {
  location = "UKSouth"
  name     = "IngeniiSolutions"
}

resource "azurerm_databricks_workspace" "this" {
  location = azurerm_resource_group.this.location
  tags     = { Owner = "Developer" }

  name                        = "example"
  resource_group_name         = azurerm_resource_group.this.name
  managed_resource_group_name = "${azurerm_resource_group.this.name}-databricks"

  sku = "trial"
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.this.id
}

module "high_concurrency_cluster" {
  source  = "ingenii-solutions/cluster/databricks"
  version = "x.x.x"

  name = "high-concurrency-cluster"
  tags = { Owner = "Developer" }

  cluster_mode                 = "high_concurrency"
  cluster_runtime_version_type = "beta"

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
```

## Inputs

<!--- <<ii-tf-inputs-begin>> -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the cluster. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key/value pairs of tags that will be applied to all resources in this module. | `map(string)` | n/a | yes |
| <a name="input_worker_node_type_id"></a> [worker\_node\_type\_id](#input\_worker\_node\_type\_id) | This is the instance type (e.g. 'Standard\_F4s' if the cluster is deployed in Azure) the worker nodes will use. | `string` | n/a | yes |
| <a name="input_auto_scale_max_workers"></a> [auto\_scale\_max\_workers](#input\_auto\_scale\_max\_workers) | If auto scaling is desired, this value controls the maximum of cluster workers that will be deployed. | `number` | `0` | no |
| <a name="input_auto_scale_min_workers"></a> [auto\_scale\_min\_workers](#input\_auto\_scale\_min\_workers) | If auto scaling is desired, this value controls the minimum of cluster workers that will be deployed. | `number` | `0` | no |
| <a name="input_auto_termination_in_minutes"></a> [auto\_termination\_in\_minutes](#input\_auto\_termination\_in\_minutes) | The number of minutes that the cluster can be idle, before its automatically terminated. | `number` | `10` | no |
| <a name="input_aws_attributes"></a> [aws\_attributes](#input\_aws\_attributes) | Applies only if the cluster is deployed in AWS. Additional attributes: https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster#aws_attributes | `map(string)` | `{}` | no |
| <a name="input_azure_attributes"></a> [azure\_attributes](#input\_azure\_attributes) | Applies only if the cluster is deployed in Azure. Additional attributes: https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster#azure_attributes | `map(string)` | `{}` | no |
| <a name="input_azure_data_lake_storage_credential_passthrough_is_enabled"></a> [azure\_data\_lake\_storage\_credential\_passthrough\_is\_enabled](#input\_azure\_data\_lake\_storage\_credential\_passthrough\_is\_enabled) | Controls wether AAD pass trough is enabled. | `bool` | `false` | no |
| <a name="input_cluster_mode"></a> [cluster\_mode](#input\_cluster\_mode) | n/a | `string` | `"standard"` | no |
| <a name="input_cluster_runtime_scala_version"></a> [cluster\_runtime\_scala\_version](#input\_cluster\_runtime\_scala\_version) | The specific Scala version that this cluster should run. | `string` | `""` | no |
| <a name="input_cluster_runtime_spark_version"></a> [cluster\_runtime\_spark\_version](#input\_cluster\_runtime\_spark\_version) | The specific Spark version that this cluster should run. | `string` | `"3"` | no |
| <a name="input_cluster_runtime_version_only_genomics"></a> [cluster\_runtime\_version\_only\_genomics](#input\_cluster\_runtime\_version\_only\_genomics) | Limit the search for Genomics(HLS) runtimes only. | `bool` | `false` | no |
| <a name="input_cluster_runtime_version_only_gpu"></a> [cluster\_runtime\_version\_only\_gpu](#input\_cluster\_runtime\_version\_only\_gpu) | Limit the search for runtimes that support GPUs. | `bool` | `false` | no |
| <a name="input_cluster_runtime_version_only_ml"></a> [cluster\_runtime\_version\_only\_ml](#input\_cluster\_runtime\_version\_only\_ml) | Limit the search for ML runtimes only. | `bool` | `false` | no |
| <a name="input_cluster_runtime_version_type"></a> [cluster\_runtime\_version\_type](#input\_cluster\_runtime\_version\_type) | The type of runtime version will be used by the cluster. | `string` | `"latest"` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Provide 'url', 'basic\_auth\_username (optional)' and 'basic\_auth\_password (optional)' attributes in order to get the cluster to spin up using a docker image. | `map(string)` | `{}` | no |
| <a name="input_driver_node_type_id"></a> [driver\_node\_type\_id](#input\_driver\_node\_type\_id) | The node type of the Spark driver. This field is optional; if unset, API will set the driver node type to the same value as worker\_node\_type\_id defined above. | `string` | `""` | no |
| <a name="input_elastic_disk_is_enabled"></a> [elastic\_disk\_is\_enabled](#input\_elastic\_disk\_is\_enabled) | If you don’t want to allocate a fixed number of EBS volumes at cluster creation time, use autoscaling local storage. With autoscaling local storage, Databricks monitors the amount of free disk space available on your cluster’s Spark workers. If a worker begins to run too low on disk, Databricks automatically attaches a new EBS volume to the worker before it runs out of disk space. EBS volumes are attached up to a limit of 5 TB of total disk space per instance (including the instance’s local storage). | `bool` | `true` | no |
| <a name="input_gcp_attributes"></a> [gcp\_attributes](#input\_gcp\_attributes) | Applies only if the cluster is deployed in Azure. Additional attributes: https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster#gcp_attributes | `map(string)` | `{}` | no |
| <a name="input_idempotency_token"></a> [idempotency\_token](#input\_idempotency\_token) | An optional token to guarantee the idempotency of cluster creation requests. | `string` | `""` | no |
| <a name="input_init_scripts"></a> [init\_scripts](#input\_init\_scripts) | A list of init scripts to be ran on the cluster. | <pre>list(object({<br>    name = string<br>    type = string<br>    path = string<br>  }))</pre> | `[]` | no |
| <a name="input_instance_pool_id"></a> [instance\_pool\_id](#input\_instance\_pool\_id) | The predefined instance pool id this cluster will attach to. | `string` | `""` | no |
| <a name="input_is_pinned"></a> [is\_pinned](#input\_is\_pinned) | n/a | `bool` | `false` | no |
| <a name="input_local_disk_encryption_is_enabled"></a> [local\_disk\_encryption\_is\_enabled](#input\_local\_disk\_encryption\_is\_enabled) | Some instance types you use to run clusters may have locally attached disks. Databricks may store shuffle data or temporary data on these locally attached disks. To ensure that all data at rest is encrypted for all storage types, including shuffle data stored temporarily on your cluster’s local disks, you can enable local disk encryption. | `bool` | `false` | no |
| <a name="input_number_of_workers"></a> [number\_of\_workers](#input\_number\_of\_workers) | The number of workers, if the cluster is going to be of a fixed size. | `number` | `0` | no |
| <a name="input_policy_id"></a> [policy\_id](#input\_policy\_id) | The id of the policy that will be applied to this cluster. | `string` | `""` | no |
| <a name="input_pypi_packages"></a> [pypi\_packages](#input\_pypi\_packages) | A list of PyPi packages to be installed on the cluster. | <pre>list(object({<br>    name    = string<br>    version = string<br>  }))</pre> | `[]` | no |
| <a name="input_single_user_name"></a> [single\_user\_name](#input\_single\_user\_name) | The optional user name of the user to assign to an interactive cluster. This field is required when using standard AAD Passthrough for Azure Data Lake Storage (ADLS) with a single-user cluster (i.e., not high-concurrency clusters). | `string` | `""` | no |
| <a name="input_spark_config"></a> [spark\_config](#input\_spark\_config) | Additional spark configs (key/value) can be passed on using this input variable. | `map(string)` | `{}` | no |
| <a name="input_spark_env_vars"></a> [spark\_env\_vars](#input\_spark\_env\_vars) | Additional environment variables (key/value) can be passed to the cluster using this input variable. | `map(string)` | `{}` | no |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | A list of SSH public keys that will be trusted by the cluster. | `list(string)` | `[]` | no |
<!--- <<ii-tf-inputs-end>> -->

## Outputs

<!--- <<ii-tf-outputs-begin>> -->
| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the cluster. |
| <a name="output_cluster_state"></a> [cluster\_state](#output\_cluster\_state) | The state of the cluster. |
<!--- <<ii-tf-outputs-end>> -->

## Nested Modules

<!--- <<ii-tf-modules-begin>> -->
No modules.
<!--- <<ii-tf-modules-end>> -->

## Resource Types

<!--- <<ii-tf-resources-begin>> -->
| Name | Type |
|------|------|
| [databricks_cluster.this](https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster) | resource |
<!--- <<ii-tf-resources-end>> -->

## Related Modules

- N/A

## Solutions Using This Module

- N/A
