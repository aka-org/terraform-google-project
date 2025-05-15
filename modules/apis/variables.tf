variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "enable_apis" {
  description = "Lists of Google APIs to be enabled"
  type        = list(string)
  default     = []
}
