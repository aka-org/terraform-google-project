output "identity_provider_github_ids" {
  description = "List of workload identity providers for Github Actions"
  value = var.gha_wif_enabled ? [
    for repo in var.gha_allowed_repos : google_iam_workload_identity_pool_provider.github_repos[repo].workload_identity_pool_provider_id
  ] : null
}

output "identity_provider_github_full_ids" {
  description = "List of full paths of workload identity providers for Github Actions"
  value = var.gha_wif_enabled ? [
    for repo in var.gha_allowed_repos : google_iam_workload_identity_pool_provider.github_repos[repo].name
  ] : null
}
