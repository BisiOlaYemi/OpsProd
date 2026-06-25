provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "tags" {
  source = "../shared/modules/tags"

  environment = var.environment
  project     = var.project
  owner       = var.owner
}

locals {
  labels = {
    for k, v in module.tags.tags : lower(replace(k, " ", "_")) => lower(replace(v, " ", "_"))
  }
}
