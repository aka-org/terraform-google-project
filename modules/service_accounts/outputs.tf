output "sa_emails" {
  description = "List of service accounts emails"
  value       = [for sa in var.service_accounts : google_service_account.sa[sa.id].email]
}

output "sa_ids" {
  description = "List of service accounts ids"
  value       = [for sa in var.service_accounts : google_service_account.sa[sa.id].account_id]
}
