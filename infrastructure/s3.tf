resource "random_id" "static_suffix" {
  byte_length = 4
}

# 🎨 Frontend public bucket
resource "aws_s3_bucket" "frontend" {
  bucket        = "converteasy-static-site-${random_id.static_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "FrontendStaticWebsite"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_site" {
  bucket = aws_s3_bucket.frontend.bucket

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

# 🔒 Private upload bucket
resource "aws_s3_bucket" "uploaded" {
  bucket        = "converteasy-uploaded-files"
  force_destroy = true
  tags          = { Name = "UploadedFiles" }
}

resource "aws_s3_bucket" "converted" {
  bucket        = "converteasy-converted-files"
  force_destroy = true
  tags          = { Name = "ConvertedFiles" }
}

# 🔐 Block public access to private buckets
resource "aws_s3_bucket_public_access_block" "uploaded_block" {
  bucket                  = aws_s3_bucket.uploaded.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "converted_block" {
  bucket                  = aws_s3_bucket.converted.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


# ⏱ Lifecycle rules (simulate 1-hour cleanup with 1-day TTL)
resource "aws_s3_bucket_lifecycle_configuration" "uploaded_ttl" {
  bucket = aws_s3_bucket.uploaded.id

  rule {
    id     = "expire-uploads"
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
    id     = "expire-converted"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_public" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.frontend_block]
}

