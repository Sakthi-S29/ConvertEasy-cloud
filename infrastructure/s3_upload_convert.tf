# ✅ Terraform to create private S3 buckets for uploaded + converted files with auto-delete (TTL after 1 hour)

resource "aws_s3_bucket" "uploaded" {
  bucket = "converteasy-uploaded-files"
  force_destroy = true

  tags = {
    Name = "ConvertEasyUploaded"
  }
}

resource "aws_s3_bucket" "converted" {
  bucket = "converteasy-converted-files"
  force_destroy = true

  tags = {
    Name = "ConvertEasyConverted"
  }
}

# 🔐 Block all public access for both buckets
resource "aws_s3_bucket_public_access_block" "uploaded" {
  bucket = aws_s3_bucket.uploaded.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "converted" {
  bucket = aws_s3_bucket.converted.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 🕒 Add lifecycle rules to auto-delete files after 1 hour (~0 days)
resource "aws_s3_bucket_lifecycle_configuration" "uploaded_ttl" {
  bucket = aws_s3_bucket.uploaded.id

  rule {
    id     = "expire-uploads-after-1-hour"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "converted_ttl" {
  bucket = aws_s3_bucket.converted.id

  rule {
    id     = "expire-converted-after-1-hour"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 1
    }
  }
}

output "uploaded_bucket" {
  value       = aws_s3_bucket.uploaded.bucket
  description = "S3 bucket for uploaded files (private)"
}

output "converted_bucket" {
  value       = aws_s3_bucket.converted.bucket
  description = "S3 bucket for converted files (private)"
}
