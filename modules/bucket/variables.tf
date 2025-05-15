variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "gcs_backend" {
  description = "If true creates bucket named after project id to store tf states and a local backend.tf"
  type        = bool
  default     = false
}

variable "bucket" {
  description = "Object describing a bucket for project tf states"
  type = object({
    location           = string
    force_destroy      = bool
    versioning_enabled = bool
    labels             = map(string)
  })
  default = {
    location           = "us-east1"
    force_destroy      = false
    versioning_enabled = true
    labels             = {}
  }
}
