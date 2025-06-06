output "sa_email" {
  description = "Default service account email"
  value       = google_service_account.default_sa.email
}

output "sa_id" {
  description = "Default service account id"
  value       = google_service_account.default_sa.account_id
}

output "sa_name" {
  description = "Default service account fully-qualified name"
  value       = google_service_account.default_sa.name
}
