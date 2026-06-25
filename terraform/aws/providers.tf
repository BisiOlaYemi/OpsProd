provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.tags.tags
  }

  assume_role {
    role_arn     = var.deployment_role_arn
    session_name = "terraform-secure-baseline"
  }

  allowed_account_ids = [var.aws_account_id]
}

module "tags" {
  source = "../shared/modules/tags"

  environment = var.environment
  project     = var.project
  owner       = var.owner
}
