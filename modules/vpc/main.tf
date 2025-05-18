locals {
  sa_roles = [
    "roles/compute.networkAdmin",
    "roles/compute.admin"
  ]
}

data "google_service_account" "default_sa" {
  for_each = var.vpc_create ? toset([var.sa_id]) : toset([])

  account_id = each.value
  project    = var.project_id
}

resource "google_project_service" "enabled_apis" {
  for_each = var.vpc_create ? toset(["compute.googleapis.com"]) : toset([])

  project = var.project_id
  service = each.value
}

resource "google_project_iam_member" "default_sa_roles" {
  for_each = var.vpc_create ? toset(local.sa_roles) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_service_account.default_sa[var.sa_id].email}"
}

resource "google_compute_network" "vpc" {
  count = var.vpc_create ? 1 : 0

  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  depends_on = [
    google_project_service.enabled_apis["compute.googleapis.com"],
    google_project_iam_member.default_sa_roles["roles/compute.networkAdmin"],
    google_project_iam_member.default_sa_roles["roles/compute.admin"]
  ]
}
