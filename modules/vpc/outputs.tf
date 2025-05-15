output "vpc_name" {
  description = "Name of the project vpc"
  value       = var.create_vpc ? google_compute_network.vpc[0].name : null
}

output "vpc_self_link" {
  description = "Self link to the project vpc"
  value       = var.create_vpc ? google_compute_network.vpc[0].self_link : null
}
