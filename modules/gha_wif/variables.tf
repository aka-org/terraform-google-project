variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "gha_wif_enabled" {
  description = "Set to true to setup Workload Identity Federation for Github Actions"
  type        = bool
  default     = false
}

variable "sa_ids" {
  description = "A list of ids corresponding to all available service accounts"
  type        = list(string)
  default     = []
}

variable "gha_wif_sa" {
  description = "Service account to be associated with Github identity pool, must be defined in service accounts"
  type        = string
  default     = ""
}

variable "gha_wif_org" {
  description = "Github org or user from which actions are allowed to authenticate via WIF"
  type        = string
  default     = ""
}

variable "gha_wif_repo" {
  description = "Github repo from which actions are allowed to authenticate via WIF"
  type        = string
  default     = ""
}
