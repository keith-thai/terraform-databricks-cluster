########################################################################################################################
# Data Sources
########################################################################################################################
data "databricks_spark_version" "this" {
  beta              = contains([var.cluster_runtime_version_type], "beta")
  long_term_support = contains([var.cluster_runtime_version_type], "lts")
  latest            = contains([var.cluster_runtime_version_type], "latest")
  spark_version     = var.cluster_runtime_spark_version
  scala             = var.cluster_runtime_scala_version
  ml                = var.cluster_runtime_version_only_ml
  genomics          = var.cluster_runtime_version_only_genomics
  gpu               = var.cluster_runtime_version_only_gpu
}

########################################################################################################################
# Local Values
########################################################################################################################
locals {
  cluster_modes = {
    single_node = {
      spark_config = {
        "spark.databricks.cluster.profile" : "singleNode"
        "spark.master" : "local[*]"
        "spark.databricks.passthrough.enabled" : "${var.azure_data_lake_storage_credential_passthrough_is_enabled}"
      }
      tags = {
        "ResourceClass" = "SingleNode"
      }
      env_vars = {
        PYSPARK_PYTHON = "/databricks/python3/bin/python3"
      }
      number_of_workers = 0
    }

    standard = {
      spark_config = {
        "spark.databricks.passthrough.enabled" : "${var.azure_data_lake_storage_credential_passthrough_is_enabled}"
      }
      tags = {}
      env_vars = {
        PYSPARK_PYTHON = "/databricks/python3/bin/python3"
      }
      number_of_workers = var.number_of_workers == 0 ? 1 : var.number_of_workers
    }

    high_concurrency = {
      spark_config = {
        "spark.databricks.cluster.profile" : "serverless"
        "spark.databricks.repl.allowedLanguages" : "sql,python,r"
        "spark.databricks.passthrough.enabled" : "${var.azure_data_lake_storage_credential_passthrough_is_enabled}"
      }
      tags = {
        "ResourceClass" = "Serverless"
      }
      env_vars = {
        PYSPARK_PYTHON = "/databricks/python3/bin/python3"
      }
      number_of_workers = var.number_of_workers == 0 ? 1 : var.number_of_workers
    }
  }
}

########################################################################################################################
# Databricks Cluster
########################################################################################################################
locals {
  current_cluster_config = {
    spark_version  = data.databricks_spark_version.this.id
    spark_config   = merge(local.cluster_modes[var.cluster_mode].spark_config, var.spark_config)
    spark_env_vars = merge(local.cluster_modes[var.cluster_mode].env_vars, var.spark_env_vars)
    tags = merge(local.cluster_modes[var.cluster_mode].tags,
      # Databricks expects all custom tags to have a prefix -> "x_"
      { for tag_key in keys(var.tags) : "x_${tag_key}" => var.tags["${tag_key}"] }
    )

    number_of_workers = local.cluster_modes[var.cluster_mode].number_of_workers
    auto_scale_config = var.auto_scale_min_workers > 0 && var.auto_scale_max_workers > 0 ? [
      {
        min_workers = var.auto_scale_min_workers
        max_workers = var.auto_scale_max_workers
      }
    ] : []

    cluster_log_conf = len(var.dbfs_log_path) > 0 ? [concat("dbfs://", trim(var.dbfs_log_path, "/"))] : []

    init_scripts = {
      dbfs = [for script in var.init_scripts : script if script.type == "dbfs"]
      s3   = [for script in var.init_scripts : script if script.type == "s3"]
      file = [for script in var.init_scripts : script if script.type == "file"]
    }

    docker_image = length(keys(var.docker_image)) > 0 ? [
      {
        url = var.docker_image.url
        basic_auth = try(var.docker_image.basic_auth_username, "") != "" && try(var.docker_image.basic_auth_password, "") != "" ? [
          {
            username = var.docker_image.basic_auth_username
            password = var.docker_image.basic_auth_password
          }
        ] : []
      }
    ] : []

    aws_attributes = length(keys(var.aws_attributes)) > 0 ? [
      {
        availability           = try(var.aws_attributes.availability, "SPOT")
        zone_id                = var.aws_attributes.zone_id
        first_on_demand        = try(var.aws_attributes.first_on_demand, 1)
        spot_bid_price_percent = try(var.aws_attributes.spot_bid_price_percent, 100)
        instance_profile_arn   = try(var.aws_attributes.instance_profile_arn, null)
        ebs_volume_type        = try(var.aws_attributes.ebs_volume_type, null)
        ebs_volume_count       = try(var.aws_attributes.ebs_volume_count, null)
        ebs_volume_size        = try(var.aws_attributes.ebs_volume_size, null)
      }
    ] : []

    azure_attributes = length(keys(var.azure_attributes)) > 0 ? [
      {
        availability       = try(var.azure_attributes.availability, "SPOT_AZURE")
        first_on_demand    = try(var.azure_attributes.first_on_demand, 1)
        spot_bid_max_price = try(var.azure_attributes.spot_bid_max_price, 100)
      }
    ] : []

    gcp_attributes = length(keys(var.gcp_attributes)) > 0 ? [
      {
        use_preemptible_executors = try(var.gcp_attributes.use_preemptible_executors, true)
        google_service_account    = try(var.gcp_attributes.google_service_account, null)
      }
    ] : []

    libraries = {
      pypi_packages = {
        for package in var.pypi_packages : package.name => {
          package = "${package.name}==${package.version}"
          repo    = try(package.repo, null)
        }
      }
    }
  }
}

resource "databricks_cluster" "this" {
  cluster_name                 = var.name
  custom_tags                  = local.current_cluster_config.tags
  is_pinned                    = var.is_pinned
  spark_version                = local.current_cluster_config.spark_version
  spark_env_vars               = local.current_cluster_config.spark_env_vars
  spark_conf                   = local.current_cluster_config.spark_config
  driver_node_type_id          = var.driver_node_type_id
  node_type_id                 = var.worker_node_type_id
  num_workers                  = local.current_cluster_config.number_of_workers
  autotermination_minutes      = var.auto_termination_in_minutes
  idempotency_token            = var.idempotency_token
  instance_pool_id             = var.instance_pool_id
  policy_id                    = var.policy_id
  enable_elastic_disk          = var.elastic_disk_is_enabled
  enable_local_disk_encryption = var.local_disk_encryption_is_enabled
  ssh_public_keys              = var.ssh_public_keys
  single_user_name             = var.single_user_name

  dynamic "autoscale" {
    for_each = local.current_cluster_config.auto_scale_config
    iterator = i
    content {
      min_workers = i.value.min_workers
      max_workers = i.value.max_workers
    }
  }

  dynamic "cluster_log_conf" {
    for_each = local.current_cluster_config.cluster_log_conf
    iterator = i
    content {
      dbfs {
        destination = i
      }
    }
  }

  dynamic "aws_attributes" {
    for_each = local.current_cluster_config.aws_attributes
    iterator = i
    content {
      availability           = i.value.availability
      zone_id                = i.value.zone_id
      first_on_demand        = i.value.first_on_demand
      spot_bid_price_percent = i.value.spot_bid_price_percent
      instance_profile_arn   = i.value.instance_profile_arn
      ebs_volume_type        = i.value.ebs_volume_type
      ebs_volume_count       = i.value.ebs_volume_count
      ebs_volume_size        = i.value.ebs_volume_size
    }
  }

  dynamic "azure_attributes" {
    for_each = local.current_cluster_config.aws_attributes
    iterator = i
    content {
      availability       = i.value.availability
      first_on_demand    = i.value.first_on_demand
      spot_bid_max_price = i.value.spot_bid_max_price
    }
  }

  dynamic "gcp_attributes" {
    for_each = local.current_cluster_config.aws_attributes
    iterator = i
    content {
      use_preemptible_executors = i.value.use_preemptible_executors
      google_service_account    = i.value.google_service_account
    }
  }

  dynamic "docker_image" {
    for_each = local.current_cluster_config.docker_image
    iterator = i
    content {
      url = i.value.url
      dynamic "basic_auth" {
        for_each = i.value.basic_auth
        iterator = j
        content {
          username = j.value.username
          password = j.value.password
        }
      }
    }
  }

  dynamic "library" {
    for_each = local.current_cluster_config.libraries.pypi_packages
    iterator = i
    content {
      pypi {
        package = i.value.package
        repo    = i.value.repo
      }
    }
  }

  dynamic "init_scripts" {
    for_each = local.current_cluster_config.init_scripts.dbfs
    iterator = i
    content {
      dbfs {
        destination = i.value.path
      }
    }
  }

  dynamic "init_scripts" {
    for_each = local.current_cluster_config.init_scripts.s3
    iterator = i
    content {
      s3 {
        destination = i.value.path
        region      = try(i.value.region, "us-east-1")
      }
    }
  }

  dynamic "init_scripts" {
    for_each = local.current_cluster_config.init_scripts.file
    iterator = i
    content {
      file {
        destination = i.value.path
      }
    }
  }
}
