resource "google_storage_bucket" "this" {
  count = var.bucket != null ? 1 : 0

  name          = "${var.project_id}-tf-states"
  location      = var.bucket.location
  project       = var.project_id
  force_destroy = var.bucket.force_destroy
  versioning {
    enabled = var.bucket.versioning_enabled
  }
  labels = var.bucket.labels
}

resource "local_file" "gcs_backend" {
  count = var.gcs_backend && var.bucket != null ? 1 : 0

  file_permission = "0644"
  filename        = "${path.cwd}/backend.tf"

  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.this[0].name}"
      prefix = "project"
    }
  }
  EOT
}
