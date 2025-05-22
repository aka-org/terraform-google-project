resource "google_project_iam_member" "default_sa_roles" {
  for_each = var.vpc_create ? toset(["roles/compute.networkAdmin"]) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.sa_email}"
}

resource "google_compute_network" "vpc" {
  count = var.vpc_create ? 1 : 0

  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  depends_on = [
    google_project_iam_member.default_sa_roles["roles/compute.networkAdmin"]
  ]
}
