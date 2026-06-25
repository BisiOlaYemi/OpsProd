variable "azure_subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure AD tenant ID."
  type        = string
}

variable "azure_location" {
  description = "Primary Azure region."
  type        = string
  default     = "eastus"
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
  description = "Resource owner."
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual network address space."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "log_retention_days" {
  description = "Diagnostic and audit log retention."
  type        = number
  default     = 365
}

variable "azure_name_prefix" {
  description = "Short globally unique prefix for Azure resources with strict name limits (3-8 lowercase alphanumeric)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.azure_name_prefix))
    error_message = "azure_name_prefix must be 3-8 lowercase alphanumeric characters."
  }
}
