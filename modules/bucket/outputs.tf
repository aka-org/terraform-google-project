output "bucket_name" {
  description = "The name of the bucket"
  value       = google_storage_bucket.this[0].name
}

output "bucket_labels" {
  description = "The labels of the bucket"
  value       = google_storage_bucket.this[0].labels
}