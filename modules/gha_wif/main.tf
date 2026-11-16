locals {
  # A provider's id is its repository's name, made to fit what Google
  # accepts for one: lowercase letters, digits and hyphens, 4 to 32
  # characters, not starting with the reserved "gcp-". A name that already
  # fits is used as it is; one that is too short or starts with "gcp-"
  # gets the prefix "gh-" (aka-org/gcp-infra -> gh-gcp-infra).
  repo_names = {
    for repo in var.gha_allowed_repos : repo => replace(lower(split("/", repo)[1]), "/[^a-z0-9-]/", "-")
  }
  provider_ids = {
    for repo, name in local.repo_names : repo => substr(
      length(name) < 4 || startswith(name, "gcp-") ? "gh-${name}" : name, 0, 32
    )
  }
}

resource "random_id" "pool_suffix" {
  count       = var.gha_wif_enabled ? 1 : 0
  byte_length = 4
}

resource "google_project_iam_member" "default_sa_roles" {
  for_each = var.gha_wif_enabled ? toset(["roles/iam.workloadIdentityPoolAdmin"]) : []

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.sa_email}"
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
  workload_identity_pool_provider_id = local.provider_ids[each.value]
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
    # The branch or tag the workflow runs for (refs/heads/main), mapped so
    # a caller's own IAM binding can limit an identity to one ref.
    "attribute.ref" = "assertion.ref"
  }

  attribute_condition = <<EOT
    attribute.repository == "${each.value}" &&
    attribute.repository_owner_id == "${var.gha_owner_id}"
EOT
}

resource "google_service_account_iam_member" "default_sa_repo_bindings" {
  for_each = var.gha_wif_enabled ? toset(var.gha_allowed_repos) : toset([])

  service_account_id = var.sa_name

  role   = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/attribute.repository/${each.value}"
}
