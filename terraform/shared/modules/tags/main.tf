locals {
  standard = merge(
    {
      Environment       = var.environment
      Project           = var.project
      Owner             = var.owner
      ManagedBy         = "terraform"
      ComplianceScope   = join(",", var.compliance_scope)
      SecurityBaseline  = "multi-cloud-secure-baseline"
    },
    var.additional_tags
  )
}

output "tags" {
  description = "Standardized resource tags for multi-cloud compliance tracking."
  value       = local.standard
}
