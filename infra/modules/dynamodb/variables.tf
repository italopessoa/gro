variable "environment" {
  type        = string
  description = "The deployment environment name"
}

variable "project" {
  type        = string
  description = "The project name"
  default     = "pgr-mental"
}
