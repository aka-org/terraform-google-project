variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "service_accounts" {
  description = "List of service accounts with role bindings"
  type = list(object({
    id          = string
    description = string
    roles       = list(string)
  }))
  default = []
}