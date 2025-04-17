# ✅ Terraform to create a public S3 static website with index.html (without editing bucket policy)

resource "aws_s3_bucket" "frontend_site" {
  bucket = "converteasy-static-site-sakthi"
  force_destroy = true

  tags = {
    Name = "ConvertEasyPublicSite"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend_site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.frontend_site.id

  block_public_acls       = false
  block_public_policy     = false   # This allows us to avoid setting bucket policy manually
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.frontend_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend_site.arn}/*"
      }
    ]
  })
}

output "s3_website_url" {
  description = "Static website URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}
