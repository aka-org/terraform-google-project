variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "create_vpc" {
  description = "Set to true to create a default project vpc"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "The name of the vpc"
  type        = string
  default     = ""
}