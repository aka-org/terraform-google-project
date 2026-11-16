variable "project_name" {
  description = "A human-readable name for the project"
  type        = string
}

variable "project_labels" {
  description = "Labels to add to project"
  type        = map(string)
  default     = {}
}

variable "project_deletion_policy" {
  description = "Project deletion policy (e.g. PREVENT or DELETE)"
  type        = string
  default     = "PREVENT"
}

variable "billing_account_id" {
  description = "Billing account ID to associate with the project"
  type        = string
  sensitive   = true
}

variable "enable_apis" {
  description = "Lists of additional Google APIs to be enabled"
  type        = list(string)
  default     = []
}

variable "bucket_name_prefix" {
  description = "The prefix of the name of the bucket that will store the tf states"
  type        = string
  default     = ""
  nullable    = false
}

variable "bucket_location" {
  description = "Location of the bucket corresponding to google regions"
  type        = string
  default     = "us-east1"
}

variable "bucket_force_destroy" {
  description = "Set to true to allow the bucket to be destroyed even if it is storing content"
  type        = bool
  default     = false
}

variable "bucket_versioning" {
  description = "Set to true to enable versioning of bucket contents"
  type        = bool
  default     = true
}

variable "bucket_uniform_access" {
  description = "Set to true to control access to the bucket through IAM only (no per-object ACLs)"
  type        = bool
  default     = true
}

variable "bucket_public_access_prevention" {
  description = "Public access prevention of the bucket: enforced (it can never be made public) or inherited (the organization's policy decides)"
  type        = string
  default     = "enforced"

  validation {
    condition     = contains(["enforced", "inherited"], var.bucket_public_access_prevention)
    error_message = "bucket_public_access_prevention must be \"enforced\" or \"inherited\"."
  }
}

variable "bucket_labels" {
  description = "Labels to add to the created bucket"
  type        = map(string)
  default     = {}
}

variable "gcs_backend" {
  description = "If true creates bucket named after project id to store tf states and a local backend.tf"
  type        = bool
  default     = false
}

variable "sa_id" {
  description = "The id of the default service account"
  type        = string
  default     = "terraform-sa"
}

variable "sa_description" {
  description = "Description of the default service account"
  type        = string
  default     = "Default service account used by Terraform"
}

variable "sa_roles" {
  description = "List of roles to be assigned to the default service account"
  type        = list(string)
  default = [
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin"
  ]
}

variable "remove_editor_members" {
  description = "If true, removes every member of roles/editor once at creation (the default Compute Engine service account and the Google APIs Service Agent included). Set to false to leave the role's members as Google grants them"
  type        = bool
  default     = true
}

variable "gha_wif_enabled" {
  description = "Set to true to setup Workload Identity Federation for Github Actions"
  type        = bool
  default     = false
}

variable "gha_owner_id" {
  description = "ID of the owner of the github repos allowed to authenticate via identity provider"
  type        = string
  default     = ""
}

variable "gha_allowed_repos" {
  description = "List of repos allowed to authenticate via identity provider"
  type        = list(string)
  default     = []
}

variable "vpc_create" {
  description = "Set to true to create a default project vpc"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of the project vpc"
  type        = string
  default     = ""
}
