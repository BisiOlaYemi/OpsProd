variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "Primary GCP region."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "project" {
  description = "Project name for labeling."
  type        = string
}

variable "owner" {
  description = "Resource owner."
  type        = string
}

variable "vpc_cidr" {
  description = "Primary subnet CIDR."
  type        = string
  default     = "10.10.0.0/16"
}

variable "log_retention_days" {
  description = "Audit log retention."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 90
    error_message = "log_retention_days must be at least 90 for production."
  }
}

variable "terraform_sa_email" {
  description = "Service account email used by Terraform deployments."
  type        = string
}

variable "organization_id" {
  description = "GCP organization ID for SCC notifications. Leave empty to skip org-level SCC routing."
  type        = string
  default     = ""
}
