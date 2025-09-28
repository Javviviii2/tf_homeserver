output "client_configuration" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.this
  sensitive   = true
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = resource.talos_cluster_kubeconfig.this
  sensitive   = true
}

output "machine_config" {
  description = "Machine configurations"
  value       = data.talos_machine_configuration.this
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = var.cluster.endpoint
}

output "nodes" {
  description = "Node information"
  value       = var.nodes
}