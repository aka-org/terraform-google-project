resource "google_project_service" "enabled_apis" {
  for_each = toset(["iam.googleapis.com"])

  project = var.project_id
  service = each.value
}

resource "google_project_iam_binding" "remove_default_sa_access" {
  project = var.project_id
  role    = "roles/editor"

  members = [] # Remove all members from this role
  depends_on   = [google_project_service.enabled_apis["iam.googleapis.com"]]
}

resource "google_service_account" "default_sa" {
  project      = var.project_id
  account_id   = var.sa_id
  display_name = var.sa_description
  depends_on   = [google_project_service.enabled_apis["iam.googleapis.com"]]
}

resource "google_project_iam_member" "default_sa_roles" {
  for_each = toset(var.sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.default_sa.email}"
}
