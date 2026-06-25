output "vpc_name" {
  value = google_compute_network.this.name
}

output "private_subnet_name" {
  value = google_compute_subnetwork.private.name
}

output "audit_bucket_name" {
  value = google_storage_bucket.audit.name
}

output "kms_key_id" {
  value = google_kms_crypto_key.platform.id
}

output "audit_log_sink_writer" {
  value = google_logging_project_sink.audit.writer_identity
}
