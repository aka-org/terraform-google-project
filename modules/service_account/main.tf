locals {
  default_sa_roles = [
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin"
  ]
  sa_roles = concat(local.default_sa_roles, var.sa_roles)
}

resource "google_project_iam_binding" "remove_default_sa_access" {
  project = var.project_id
  role    = "roles/editor"

  members = [] # Remove all members from this role
  lifecycle {
    ignore_changes = [members]
  }
}

resource "google_service_account" "default_sa" {
  project      = var.project_id
  account_id   = var.sa_id
  display_name = var.sa_description
}

resource "google_project_iam_member" "default_sa_roles" {
  for_each = toset(local.sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.default_sa.email}"
}
