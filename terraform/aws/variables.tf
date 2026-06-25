variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID; provider rejects operations outside this account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit account ID."
  }
}

variable "deployment_role_arn" {
  description = "IAM role assumed by Terraform with least-privilege deployment permissions."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "project" {
  description = "Project name for tagging."
  type        = string
}

variable "owner" {
  description = "Resource owner for tagging."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for multi-AZ subnets."
  type        = list(string)
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs to encrypted S3."
  type        = bool
  default     = true
}

variable "cloudtrail_log_retention_days" {
  description = "CloudTrail log retention in the audit bucket."
  type        = number
  default     = 365

  validation {
    condition     = var.cloudtrail_log_retention_days >= 90
    error_message = "CloudTrail retention must be at least 90 days for production."
  }
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks permitted for administrative ingress (keep minimal)."
  type        = list(string)
  default     = []
}
