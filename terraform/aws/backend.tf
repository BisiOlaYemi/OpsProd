terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_STATE_BUCKET"
    key            = "aws/secure-baseline/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "REPLACE_WITH_KMS_KEY_ARN"
    dynamodb_table = "REPLACE_WITH_LOCK_TABLE"
  }
}
