# Create Logging bucket
# Logging is disabled on the logging bucket to avoid an infinite loop
# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name
}

# Create a KMS key to encrypt logs with
resource "aws_kms_key" "logging_bucket_key" {
  description             = "Used to encrypt logs"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  rotation_period_in_days = 2560
}

# Create a secure public access block
resource "aws_s3_bucket_public_access_block" "logging_bucket_public_access" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt logging bucket with the KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket_encryption" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logging_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "logging_bucket_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.logging_bucket.arn
}