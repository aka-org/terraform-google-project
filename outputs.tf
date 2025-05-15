output "project_name" {
  description = "The name of the project"
  value       = module.project.project_name
}

output "project_id" {
  description = "The id of the project"
  value       = module.project.project_id
}

output "project_labels" {
  description = "The labels of the project"
  value       = module.project.project_labels
}

output "bucket_name" {
  description = "The name of the bucket"
  value       = module.bucket.bucket_name
}

output "bucket_labels" {
  description = "The labels of the bucket"
  value       = module.bucket.bucket_labels
}

output "sa_ids" {
  description = "List of service accounts ids"
  value       = module.service_accounts.sa_ids
}

output "sa_emails" {
  description = "List of service accounts emails"
  value       = module.service_accounts.sa_emails
}

output "vpc_name" {
  description = "Name of the project vpc"
  value       = module.vpc.vpc_name
}

output "vpc_self_link" {
  description = "Self link to the project vpc"
  value       = module.vpc.vpc_self_link
}
