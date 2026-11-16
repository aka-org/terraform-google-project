output "project_name" {
  description = "The name of the project"
  value       = module.project.project_name
}

output "project_id" {
  description = "The id of the project"
  value       = module.project.project_id
}

output "project_number" {
  description = "The numeric identifier of the project (used in Workload Identity principals and Google-managed service agent emails)"
  value       = module.project.project_number
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

output "sa_name" {
  description = "Default service account fully-qualified name"
  value       = module.service_account.sa_name
}

output "identity_provider_github_ids" {
  description = "Workload identity provider for Github Actions"
  value       = module.gha_wif.identity_provider_github_ids
}

output "identity_provider_github_full_ids" {
  description = "Full path of workload identity provider for Github Actions"
  value       = module.gha_wif.identity_provider_github_full_ids
}

output "plan_sa_email" {
  description = "Email of the read-only plan service account (null without gha_plan_sa_id)"
  value       = module.gha_wif.plan_sa_email
}

output "vpc_name" {
  description = "Name of the project vpc"
  value       = module.vpc.vpc_name
}

output "vpc_self_link" {
  description = "Self link to the project vpc"
  value       = module.vpc.vpc_self_link
}
