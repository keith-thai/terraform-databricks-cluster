########################################################################################################################
# REQUIRED VARIABLES
########################################################################################################################
variable "tags" {
  type        = map(string)
  description = "Key/value pairs of tags that will be applied to all resources in this module."
}

# Basics
variable "name" {
  type        = string
  description = "The name of the cluster."
}

variable "worker_node_type_id" {
  type        = string
  description = "This is the instance type (e.g. 'Standard_F4s' if the cluster is deployed in Azure) the worker nodes will use."
}

########################################################################################################################
# OPTIONAL VARIABLES
########################################################################################################################

variable "is_pinned" {
  type    = bool
  default = false
}

variable "idempotency_token" {
  type        = string
  description = "An optional token to guarantee the idempotency of cluster creation requests."
  default     = ""
}

variable "cluster_mode" {
  type = string
  validation {
    condition     = contains(["single_node", "standard", "high_concurrency"], var.cluster_mode)
    error_message = "The cluster mode can be one of: single_node, standard or high_concurrency."
  }
  default = "standard"
}

variable "dbfs_log_path" {
  type = string
  description = "The path in the DBFS that cluster logs will be written to"
  default = "cluster-logs"
}

variable "number_of_workers" {
  type        = number
  description = "The number of workers, if the cluster is going to be of a fixed size."
  default     = 0
}

variable "auto_scale_min_workers" {
  type        = number
  description = "If auto scaling is desired, this value controls the minimum of cluster workers that will be deployed."
  default     = 0
}

variable "auto_scale_max_workers" {
  type        = number
  description = "If auto scaling is desired, this value controls the maximum of cluster workers that will be deployed."
  default     = 0
}

variable "auto_termination_in_minutes" {
  type        = number
  description = "The number of minutes that the cluster can be idle, before its automatically terminated."
  default     = 10
}

variable "driver_node_type_id" {
  type        = string
  description = "The node type of the Spark driver. This field is optional; if unset, API will set the driver node type to the same value as worker_node_type_id defined above."
  default     = ""
}

variable "instance_pool_id" {
  type        = string
  description = "The predefined instance pool id this cluster will attach to."
  default     = ""
}

variable "elastic_disk_is_enabled" {
  type        = bool
  description = "If you don’t want to allocate a fixed number of EBS volumes at cluster creation time, use autoscaling local storage. With autoscaling local storage, Databricks monitors the amount of free disk space available on your cluster’s Spark workers. If a worker begins to run too low on disk, Databricks automatically attaches a new EBS volume to the worker before it runs out of disk space. EBS volumes are attached up to a limit of 5 TB of total disk space per instance (including the instance’s local storage)."
  default     = true
}

variable "local_disk_encryption_is_enabled" {
  type        = bool
  description = "Some instance types you use to run clusters may have locally attached disks. Databricks may store shuffle data or temporary data on these locally attached disks. To ensure that all data at rest is encrypted for all storage types, including shuffle data stored temporarily on your cluster’s local disks, you can enable local disk encryption."
  default     = false
}

variable "policy_id" {
  type        = string
  description = "The id of the policy that will be applied to this cluster."
  default     = ""
}

variable "cluster_runtime_version_type" {
  type        = string
  description = "The type of runtime version will be used by the cluster."
  default     = "latest"
  validation {
    condition     = contains(["lts", "latest"], var.cluster_runtime_version_type)
    error_message = "The version type can be one of: lts or latest."
  }
}

variable "cluster_runtime_spark_version" {
  type        = string
  description = "The specific Spark version that this cluster should run."
  default     = "3"
}

variable "cluster_runtime_scala_version" {
  type        = string
  description = "The specific Scala version that this cluster should run."
  default     = ""
}

variable "cluster_runtime_version_only_ml" {
  type        = bool
  description = "Limit the search for ML runtimes only."
  default     = false
}

variable "cluster_runtime_version_only_genomics" {
  type        = bool
  description = "Limit the search for Genomics(HLS) runtimes only."
  default     = false
}

variable "cluster_runtime_version_only_gpu" {
  type        = bool
  description = "Limit the search for runtimes that support GPUs."
  default     = false
}

variable "spark_env_vars" {
  type        = map(string)
  description = "Additional environment variables (key/value) can be passed to the cluster using this input variable."
  default     = {}
}

variable "spark_config" {
  type        = map(string)
  description = "Additional spark configs (key/value) can be passed on using this input variable."
  default     = {}
}

variable "aws_attributes" {
  type        = map(string) # TODO: To be converted to Object as soon as Terraform optionals are GA.
  description = "Applies only if the cluster is deployed in AWS. Additional attributes: https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster#aws_attributes"
  default     = {}
}

variable "azure_attributes" {
  type        = map(string) # TODO: To be converted to Object as soon as Terraform optionals are GA.
  description = "Applies only if the cluster is deployed in Azure. Additional attributes: https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster#azure_attributes"
  default     = {}
}

variable "gcp_attributes" {
  type        = map(string) # TODO: To be converted to Object as soon as Terraform optionals are GA.
  description = "Applies only if the cluster is deployed in Azure. Additional attributes: https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs/resources/cluster#gcp_attributes "
  default     = {}
}

variable "docker_image" {
  type        = map(string) # TODO: To be converted to Object as soon as Terraform optionals are GA.
  description = "Provide 'url', 'basic_auth_username (optional)' and 'basic_auth_password (optional)' attributes in order to get the cluster to spin up using a docker image."
  default     = {}
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "A list of SSH public keys that will be trusted by the cluster."
  default     = []
}

variable "azure_data_lake_storage_credential_passthrough_is_enabled" {
  type        = bool
  description = "Controls wether AAD pass trough is enabled."
  default     = false
}

variable "single_user_name" {
  type        = string
  description = "The optional user name of the user to assign to an interactive cluster. This field is required when using standard AAD Passthrough for Azure Data Lake Storage (ADLS) with a single-user cluster (i.e., not high-concurrency clusters)."
  default     = ""
}

variable "pypi_packages" {
  type = list(object({
    name    = string
    version = string
  }))
  description = "A list of PyPi packages to be installed on the cluster."
  default     = []
}

variable "init_scripts" {
  type = list(object({
    name = string
    type = string
    path = string
  }))
  description = "A list of init scripts to be ran on the cluster."
  default     = []
  validation {
    condition     = length(var.init_scripts) <= 10
    error_message = "The maximum number of init scripts can be 10."
  }
}
