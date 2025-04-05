resource "aws_s3_bucket" "storage_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Name        = "${var.environment}-${var.s3_bucket_name}"
    }
  )
}

resource "aws_s3_bucket_versioning" "storage_bucket" {
  bucket = aws_s3_bucket.storage_bucket.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "storage_bucket" {
  bucket = aws_s3_bucket.storage_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "s3_cors" {
  bucket = aws_s3_bucket.storage_bucket.id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = ["https://${var.domain_name}", "https://${var.www_domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = var.cors_max_age_seconds
  }
}

# Create frontend-build folder
resource "aws_s3_object" "react_build" {
  bucket  = aws_s3_bucket.storage_bucket.id
  key     = "frontend-build/"
  content = ""

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}