variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "sa_email" {
  description = "The email of the default service account"
  type        = string
}

variable "vpc_create" {
  description = "Set to true to create a default project vpc"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
  default     = ""
}
