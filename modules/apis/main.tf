resource "google_project_service" "enabled_apis" {
  for_each = toset(var.enable_apis)

  project = var.project_id
  service = each.value
}
