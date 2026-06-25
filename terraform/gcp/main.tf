
resource "google_compute_network" "this" {
  name                    = "${var.project}-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "private" {
  name          = "${var.project}-${var.environment}-private"
  ip_cidr_range = var.vpc_cidr
  region        = var.gcp_region
  network       = google_compute_network.this.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "this" {
  name    = "${var.project}-${var.environment}-router"
  region  = var.gcp_region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.project}-${var.environment}-nat"
  router                             = google_compute_router.this.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "deny_all_ingress" {
  name     = "${var.project}-${var.environment}-deny-all-ingress"
  network  = google_compute_network.this.name
  priority = 65534

  direction = "INGRESS"
  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name     = "${var.project}-${var.environment}-allow-internal"
  network  = google_compute_network.this.name
  priority = 1000

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [var.vpc_cidr]
  target_tags   = ["internal"]
}


resource "google_kms_key_ring" "platform" {
  name     = "${var.project}-${var.environment}-keyring"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "platform" {
  name            = "${var.project}-${var.environment}-cmek"
  key_ring        = google_kms_key_ring.platform.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket" "audit" {
  name                        = "${var.project}-${var.environment}-audit-${var.gcp_project_id}"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.platform.id
  }

  lifecycle_rule {
    condition {
      age = var.log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  logging {
    log_bucket        = google_storage_bucket.access_logs.name
    log_object_prefix = "audit/"
  }
}

resource "google_storage_bucket" "access_logs" {
  name                        = "${var.project}-${var.environment}-access-logs-${var.gcp_project_id}"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.platform.id
  }
}

resource "google_storage_bucket_iam_member" "audit_object_admin" {
  bucket = google_storage_bucket.audit.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.terraform_sa_email}"
}


resource "google_project_iam_custom_role" "terraform_deployer" {
  role_id     = "terraformSecureDeployer"
  title       = "Terraform Secure Deployer"
  description = "Least-privilege deployment role for secure baseline"
  permissions = [
    "compute.networks.create",
    "compute.networks.update",
    "compute.subnetworks.create",
    "compute.subnetworks.update",
    "compute.firewalls.create",
    "compute.firewalls.update",
    "compute.routers.create",
    "compute.routers.update",
    "storage.buckets.create",
    "storage.buckets.update",
    "storage.objects.create",
    "cloudkms.cryptoKeys.create",
    "cloudkms.cryptoKeys.update",
    "resourcemanager.projects.get",
    "serviceusage.services.enable",
  ]
}

resource "google_project_iam_member" "terraform_deployer" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.terraform_deployer.name
  member  = "serviceAccount:${var.terraform_sa_email}"
}


resource "google_logging_project_sink" "audit" {
  name        = "${var.project}-${var.environment}-audit-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.audit.name}"
  filter      = "logName:\"cloudaudit.googleapis.com\""

  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "audit_sink_writer" {
  bucket = google_storage_bucket.audit.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.audit.writer_identity
}

resource "google_project_service" "required" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "securitycenter.googleapis.com",
  ])

  project = var.gcp_project_id
  service = each.value

  disable_on_destroy = false
}

# Note: google_scc_organization_notification_config is not currently supported by the google-beta provider
# This resource would be used to route SCC findings to Pub/Sub for further processing
# Uncomment when provider support is available
#
# resource "google_scc_organization_notification_config" "high_severity" {
#   count = var.organization_id != "" ? 1 : 0
#
#   provider     = google-beta
#   config_id    = "${var.project}-${var.environment}-high-severity"
#   organization = var.organization_id
#   description  = "Route HIGH/CRITICAL SCC findings"
#   pubsub_topic = google_pubsub_topic.scc_findings.id
#
#   streaming_config {
#     filter = "severity=\"HIGH\" OR severity=\"CRITICAL\""
#   }
# }

resource "google_pubsub_topic" "scc_findings" {
  name = "${var.project}-${var.environment}-scc-findings"

  kms_key_name = google_kms_crypto_key.platform.id
}
