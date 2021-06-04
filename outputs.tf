########################################################################################################################
# OUTPUTS
########################################################################################################################
output "cluster_name" {
  value       = databricks_cluster.this.cluster_name
  description = "The name of the cluster."
}

output "cluster_id" {
  value       = databricks_cluster.this.id
  description = "The ID of the cluster."
}

output "cluster_state" {
  value       = databricks_cluster.this.state
  description = "The state of the cluster."
}

########################################################################################################################
# SENSITIVE OUTPUTS
########################################################################################################################
