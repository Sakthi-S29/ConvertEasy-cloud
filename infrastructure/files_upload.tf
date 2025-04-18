resource "null_resource" "inject_alb_and_upload_frontend" {
  depends_on = [
    aws_s3_bucket.frontend,
    aws_lb.backend_alb
  ]

  triggers = {
    always_run = timestamp()  # 🔁 Forces re-run every apply
  }

  provisioner "local-exec" {
    command = <<EOT
    echo "🔄 Replacing placeholder in script.template.js..."
    sed "s|%%ALB_DNS_PLACEHOLDER%%|http://${aws_lb.backend_alb.dns_name}|g" ../frontend/script.template.js > ../frontend/script.js

    echo "⬆️ Syncing frontend files to S3..."
    aws s3 sync ../frontend s3://${aws_s3_bucket.frontend.bucket}/ \
      --exact-timestamps \
      --delete

    echo "✅ Upload done!"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
