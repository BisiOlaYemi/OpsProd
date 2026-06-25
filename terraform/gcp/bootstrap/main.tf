terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

variable "gcp_project_id" { type = string }
variable "gcp_region" {
  type    = string
  default = "us-central1"
}
variable "project" { type = string }
variable "environment" { type = string }

resource "google_kms_key_ring" "state" {
  name     = "${var.project}-${var.environment}-tfstate"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "state" {
  name     = "tfstate"
  key_ring = google_kms_key_ring.state.id

  rotation_period = "7776000s"
}

resource "google_storage_bucket" "state" {
  name                        = "${var.project}-${var.environment}-tfstate-${var.gcp_project_id}"
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.state.id
  }

  public_access_prevention = "enforced"
}

output "state_bucket" {
  value = google_storage_bucket.state.name
}

output "state_kms_key" {
  value = google_kms_crypto_key.state.id
}
