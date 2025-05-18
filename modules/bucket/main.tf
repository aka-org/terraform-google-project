resource "random_id" "bucket_name_suffix" {
  byte_length = 4
}

data "google_service_account" "default_sa" {
  for_each = var.bucket_name_prefix != "" ? toset([var.sa_id]) : toset([])

  account_id = each.value
  project    = var.project_id
}

resource "google_project_service" "enabled_apis" {
  for_each = var.bucket_name_prefix != "" ? toset(["storage.googleapis.com"]) : toset([])

  project = var.project_id
  service = each.value
}

resource "google_project_iam_member" "default_sa_roles" {
  for_each = var.bucket_name_prefix != "" ? toset(["roles/storage.admin"]) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_service_account.default_sa[var.sa_id].email}"
}

resource "google_storage_bucket" "tf_states" {
  count = var.bucket_name_prefix != "" ? 1 : 0

  name          = "${var.bucket_name_prefix}-${random_id.bucket_name_suffix.hex}"
  location      = var.bucket_location
  project       = var.project_id
  force_destroy = var.bucket_force_destroy
  versioning {
    enabled = var.bucket_versioning
  }
  labels = var.bucket_labels
  depends_on = [
    google_project_service.enabled_apis["storage.googleapis.com"],
    google_project_iam_member.default_sa_roles["roles/storage.admin"]
  ]
}

resource "local_file" "gcs_backend" {
  count = var.gcs_backend && var.bucket_name_prefix != "" ? 1 : 0

  file_permission = "0644"
  filename        = "${path.cwd}/backend.tf"

  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.tf_states[0].name}"
    }
  }
  EOT
}
