locals {
  # Iterate on all service accounts and
  # generate role bindings for all service accounts
  sa_role_bindings = flatten([
    for sa in var.service_accounts : [
      for role in sa.roles : {
        id   = sa.id
        role = role
      }
    ]
  ])
}

resource "google_service_account" "sa" {
  for_each = { for sa in var.service_accounts : sa.id => sa }

  project      = var.project_id
  account_id   = each.value.id
  display_name = each.value.description
}

resource "google_project_iam_member" "sa_role" {
  for_each = {
    for binding in local.sa_role_bindings :
    "${binding.id}-${binding.role}" => binding
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.id].email}"
}
