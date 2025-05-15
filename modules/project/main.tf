resource "random_id" "project_suffix" {
  byte_length = 4
}

locals {
  project_id = "${var.project_name}-${random_id.project_suffix.hex}"
}

resource "google_project" "this" {
  name                = var.project_name
  project_id          = local.project_id
  billing_account     = var.billing_account_id
  deletion_policy     = var.project_deletion_policy
  auto_create_network = false
  labels              = var.project_labels
}

resource "google_billing_project_info" "this" {
  project         = google_project.this.project_id
  billing_account = var.billing_account_id
}
