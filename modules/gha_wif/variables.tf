variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "sa_id" {
  description = "ID of the default service account"
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
