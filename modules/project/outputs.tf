output "project_id" {
  description = "The id of the project"
  value       = google_project.this.project_id
}

output "project_name" {
  description = "The name of the project"
  value       = google_project.this.name
}

output "project_labels" {
  description = "The labels of the project"
  value       = google_project.this.labels
}