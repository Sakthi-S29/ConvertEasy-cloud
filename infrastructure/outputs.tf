output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer (backend endpoint)"
  value       = aws_lb.backend_alb.dns_name
}

output "s3_website_url" {
  description = "Public S3 URL hosting the frontend"
  value       = "http://${aws_s3_bucket.frontend.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}

output "rds_endpoint" {
  description = "PostgreSQL RDS Endpoint"
  value       = aws_db_instance.postgres.address
}

output "backend_ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "uploaded_bucket" {
  description = "Private S3 bucket for uploaded files"
  value       = aws_s3_bucket.uploaded.bucket
}

output "converted_bucket" {
  description = "Private S3 bucket for converted files"
  value       = aws_s3_bucket.converted.bucket
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "ec2_public_ip" {
  description = "Temporary public IP of backend EC2 instance"
  value       = aws_instance.backend.public_ip
}
