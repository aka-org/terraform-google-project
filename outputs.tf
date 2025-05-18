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

output "sa_email" {
  description = "Default service account email"
  value       = module.service_account.sa_email
}

output "sa_id" {
  description = "Default service account id"
  value       = module.service_account.sa_id
}

output "identity_provider_github_ids" {
  description = "Workload identity provider for Github Actions"
  value       = module.gha_wif.identity_provider_github_ids
}

output "identity_provider_github_full_ids" {
  description = "Full path of workload identity provider for Github Actions"
  value       = module.gha_wif.identity_provider_github_full_ids
}

output "vpc_name" {
  description = "Name of the project vpc"
  value       = module.vpc.vpc_name
}

output "vpc_self_link" {
  description = "Self link to the project vpc"
  value       = module.vpc.vpc_self_link
}
