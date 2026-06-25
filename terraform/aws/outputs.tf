output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for workloads."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ingress/NAT only)."
  value       = aws_subnet.public[*].id
}

output "admin_security_group_id" {
  description = "Restrictive admin security group."
  value       = aws_security_group.admin.id
}

output "platform_kms_key_arn" {
  description = "Platform KMS key ARN."
  value       = aws_kms_key.platform.arn
}

output "audit_bucket_name" {
  description = "Encrypted audit log bucket."
  value       = aws_s3_bucket.audit.bucket
}

output "cloudtrail_arn" {
  description = "Multi-region CloudTrail ARN."
  value       = aws_cloudtrail.this.arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID."
  value       = aws_guardduty_detector.this.id
}
