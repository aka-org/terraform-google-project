variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "sa_name" {
  description = "Fully-qualified name of the default service account"
  type        = string
}

variable "sa_email" {
  description = "Email of the default service account"
  type        = string
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

variable "gha_sa_refs" {
  description = "Git refs whose workflows may act as the default service account; empty allows every ref"
  type        = list(string)
  default     = []
}

variable "gha_plan_sa_id" {
  description = "The id of a read-only service account for plans on pull requests; empty creates none"
  type        = string
  default     = ""
}

variable "gha_plan_sa_roles" {
  description = "Project roles of the read-only plan service account"
  type        = list(string)
  default     = []
}

variable "state_bucket_enabled" {
  description = "Whether a state bucket exists for the plan service account to read"
  type        = bool
  default     = false
}

variable "state_bucket_name" {
  description = "The name of the state bucket"
  type        = string
  default     = null
}
