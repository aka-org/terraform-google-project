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
    id          = "gha-sa"
    description = "Service account used by Github Actions"
    roles = [
      "roles/compute.admin",
      "roles/compute.networkAdmin",
      "roles/storage.admin",
      "roles/secretmanager.admin",
      "roles/resourcemanager.projectIamAdmin",
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountKeyAdmin"
    ]
  }
]
gha_wif_enabled = true
gha_wif_sa      = "gha-sa"
gha_wif_org     = "aka-org"
gha_wif_repo    = "terraform-google-project"
create_vpc      = true
vpc_name        = "main"
