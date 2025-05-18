variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "sa_id" {
  description = "The id of the default service account"
  type        = string
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
