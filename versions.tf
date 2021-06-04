terraform {
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "~> 0.3"
    }
  }

  required_version = ">= 0.13"
}
