variable "environment" {
  description = "Deployment environment (e.g. production, staging)."
  type        = string

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "environment must be production, staging, or development."
  }
}

variable "project" {
  description = "Project or service name used for cost allocation and ownership."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,32}$", var.project))
    error_message = "project must be 3-32 lowercase alphanumeric characters or hyphens."
  }
}

variable "owner" {
  description = "Team or individual responsible for the resource."
  type        = string
}

variable "compliance_scope" {
  description = "Compliance frameworks this stack supports."
  type        = list(string)
  default     = ["cis"]
}

variable "additional_tags" {
  description = "Extra tags merged into the standard tag set."
  type        = map(string)
  default     = {}
}
