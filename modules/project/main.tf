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

resource "google_project_service" "enabled_apis" {
  for_each = toset(var.enable_apis)

  project = google_project.this.project_id
  service = each.value

  # Provider 6.x disables the API when this resource is destroyed unless
  # told otherwise; 7.x leaves it enabled. Set here so both behave the
  # same: removing an API from the list never switches it off under
  # whatever else in the project uses it.
  disable_on_destroy = false
}

resource "google_billing_project_info" "this" {
  project         = google_project.this.project_id
  billing_account = var.billing_account_id
  depends_on = [
    google_project_service.enabled_apis["cloudbilling.googleapis.com"]
  ]
}
