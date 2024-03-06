locals {
  project_name = "base-project"
}

resource "aws_s3_bucket" "tf_backend" {
  bucket_prefix = "tf-backend_${local.project_name}-"
  force_destroy = true
}

resource "aws_dynamodb_table" "tf_backend" {
  name            = "tf-backend_${local.project_name}"
  hash_key        = "LockID"
  billing_mode    = "PROVISIONED"
  read_capacity   = 5
  write_capacity  = 5

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "tf-backend-metadata" {
  value = [
    resource.aws_s3_bucket.tf_backend.bucket,
    resource.aws_dynamodb_table.tf_backend.name
  ]
}