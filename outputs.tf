output "client_configuration" {
  description = "Talos client configuration"
  value       = module.talos.client_configuration
  sensitive   = true
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = module.talos.kube_config
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.talos.cluster_endpoint
}

output "nodes" {
  description = "Node information"
  value       = module.talos.nodes
}