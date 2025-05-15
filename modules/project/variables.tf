variable "project_name" {
  description = "A human-readable prefix for the project"
  type        = string
  default     = ""
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
  default     = ""
}