#=====================================
# S3 bucket for canary artifacts
#=====================================
resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = "${module.this.id}-artifacts"
  tags   = module.this.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts_bucket" {
  bucket = aws_s3_bucket.artifacts_bucket.id

  rule {
    status = "Enabled"
    id     = "expire_canary_artifacts"

    filter {}

    expiration {
      days = var.artifacts_expiration_days
    }
  }
}
