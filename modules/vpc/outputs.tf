output "vpc_name" {
  description = "Name of the project vpc"
  value       = var.vpc_create ? google_compute_network.vpc[0].name : null
}

output "vpc_self_link" {
  description = "Self link to the project vpc"
  value       = var.vpc_create ? google_compute_network.vpc[0].self_link : null
}
