output "bucket_name" {
  description = "The name of the bucket"
  value       = var.gcs_backend ? google_storage_bucket.this[0].name : null
}

output "bucket_labels" {
  description = "The labels of the bucket"
  value       = var.gcs_backend ? google_storage_bucket.this[0].labels : null
}
