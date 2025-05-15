locals {
  gha_wif_enabled = var.gha_wif_enabled && contains(var.sa_ids, var.gha_wif_sa)
}

data "google_service_account" "gha_wif_sa" {
  count = local.gha_wif_enabled ? 1 : 0

  account_id = var.gha_wif_sa
  project    = var.project_id

}

resource "google_iam_workload_identity_pool" "github" {
  count = local.gha_wif_enabled ? 1 : 0

  project = var.project_id

  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Pool"
  description               = "Federated identity pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  count = local.gha_wif_enabled ? 1 : 0

  project = var.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.github[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "OIDC provider for GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "attribute.repository == '${var.gha_wif_org}/${var.gha_wif_repo}'"
}

resource "google_service_account_iam_member" "gha_wif_binding" {
  count = local.gha_wif_enabled ? 1 : 0

  #project           = var.project_id
  service_account_id = data.google_service_account.gha_wif_sa[0].id

  role   = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/attribute.repository/${var.gha_wif_org}/${var.gha_wif_repo}"
}
