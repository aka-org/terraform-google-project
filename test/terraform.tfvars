project_name = "tf-project"
project_labels = {
  env = "testing"
}
project_deletion_policy = "DELETE"
enable_apis = [
  "compute.googleapis.com",
  "storage.googleapis.com",
  "secretmanager.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "cloudbilling.googleapis.com",
  "serviceusage.googleapis.com",
  "iam.googleapis.com"
]
bucket = {
  location           = "us-east1"
  force_destroy      = true
  versioning_enabled = true
  labels = {
    env = "testing"
  }
}
gcs_backend = true
service_accounts = [
  {
    id          = "test-sa"
    description = "Service account used for testing sa creation"
    roles = [
      "roles/iam.serviceAccountUser"
    ]
  }
]
create_vpc = true
vpc_name   = "main"
