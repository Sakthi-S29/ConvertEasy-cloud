data "aws_caller_identity" "current" {}

resource "aws_security_group" "ec2_sg" {
  name        = "backend-ec2-sg"
  description = "Allow backend traffic from ALB"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BackendEC2SG"
  }
}

resource "aws_instance" "backend" {
  ami                         = "ami-0c101f26f147fa7fd"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  key_name = aws_key_pair.generated_key.key_name
  root_block_device {
    volume_size = 30   # <-- Increased to 20GB
    volume_type = "gp2"
  }
  user_data = templatefile("templates/docker_startup.tpl", {
    access_key    = var.aws_access_key
    secret_key    = var.aws_secret_key
    session_token = var.aws_session_token
    dynamo_table   = aws_dynamodb_table.conversion_logs.name
    upload_bucket  = aws_s3_bucket.uploaded.bucket
    converted_bucket = aws_s3_bucket.converted.bucket
    account_id     = data.aws_caller_identity.current.account_id
  })
  
  tags = {
    Name = "converteasy-backend-ec2"
  }
}
