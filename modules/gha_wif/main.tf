resource "random_id" "pool_suffix" {
  count       = var.gha_wif_enabled ? 1 : 0
  byte_length = 4
}

data "google_service_account" "default_sa" {
  for_each = var.gha_wif_enabled ? toset([var.sa_id]) : toset([])

  account_id = each.value
  project    = var.project_id
}

resource "google_project_iam_member" "default_sa_roles" {
  for_each = var.gha_wif_enabled ? toset(["roles/iam.workloadIdentityPoolAdmin"]) : []

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_service_account.default_sa[var.sa_id].email}"
}

resource "google_iam_workload_identity_pool" "github" {
  count = var.gha_wif_enabled ? 1 : 0

  project = var.project_id

  workload_identity_pool_id = "github-pool-${random_id.pool_suffix[0].hex}"
  display_name              = "GitHub Pool"
  description               = "Federated identity pool for GitHub Actions"
  depends_on = [
    google_project_iam_member.default_sa_roles["roles/iam.workloadIdentityPoolAdmin"]
  ]
}

resource "google_iam_workload_identity_pool_provider" "github_repos" {
  for_each = var.gha_wif_enabled ? toset(var.gha_allowed_repos) : toset([])

  project = var.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.github[0].workload_identity_pool_id
  workload_identity_pool_provider_id = split("/", each.value)[1]
  display_name                       = split("/", each.value)[1]
  description                        = "OIDC provider for ${each.value}"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.actor"               = "assertion.actor"
    "attribute.repository"          = "assertion.repository"
    "attribute.repository_owner_id" = "assertion.repository_owner_id"
  }

  attribute_condition = <<EOT
    attribute.repository == "${each.value}" &&
    attribute.repository_owner_id == "${var.gha_owner_id}"
EOT
}

resource "google_service_account_iam_member" "default_sa_repo_bindings" {
  for_each = var.gha_wif_enabled ? toset(var.gha_allowed_repos) : toset([])

  service_account_id = data.google_service_account.default_sa[var.sa_id].id

  role   = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/attribute.repository/${each.value}"
}
