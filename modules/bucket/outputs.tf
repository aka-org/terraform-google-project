output "bucket_name" {
  description = "The name of the bucket"
  value       = var.bucket_name_prefix != "" ? google_storage_bucket.tf_states[0].name : null
}

output "bucket_labels" {
  description = "The labels of the bucket"
  value       = var.bucket_name_prefix != "" ? google_storage_bucket.tf_states[0].labels : null
}
