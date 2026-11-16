locals {
  default_sa_roles = [
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin"
  ]
  sa_roles = concat(local.default_sa_roles, var.sa_roles)
}

# Authoritative for roles/editor: when created it removes every member
# the role has at that moment -- the default Compute Engine service
# account, and also the Google APIs Service Agent
# (<project number>@cloudservices.gserviceaccount.com), which Google
# grants Editor once the Compute Engine API is enabled. Later members
# are left alone (ignore_changes). Destroying this resource removes every
# member of the role again.
resource "google_project_iam_binding" "remove_default_sa_access" {
  count = var.remove_editor_members ? 1 : 0

  project = var.project_id
  role    = "roles/editor"

  members = [] # Remove all members from this role
  lifecycle {
    ignore_changes = [members]
  }
}

moved {
  from = google_project_iam_binding.remove_default_sa_access
  to   = google_project_iam_binding.remove_default_sa_access[0]
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
