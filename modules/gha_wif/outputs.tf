output "identity_provider_github_id" {
  description = "Workload identity provider for Github Actions"
  value       = local.gha_wif_enabled ? google_iam_workload_identity_pool_provider.github[0].workload_identity_pool_provider_id : null
}

output "identity_provider_github_full_id" {
  description = "Full path of workload identity provider for Github Actions"
  value       = local.gha_wif_enabled ? google_iam_workload_identity_pool_provider.github[0].name : null
}
