variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
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
