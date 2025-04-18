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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  key_name = aws_key_pair.generated_key.key_name
  root_block_device {
    volume_size = 20   # <-- Increased to 20GB
    volume_type = "gp2"
  }
  user_data = templatefile("templates/docker_startup.tpl", {
    db_host       = aws_db_instance.postgres.address
    db_user       = var.db_username
    db_pass       = var.db_password
    access_key    = var.aws_access_key
    secret_key    = var.aws_secret_key
    session_token = var.aws_session_token
  })

  tags = {
    Name = "converteasy-backend-ec2"
  }
}
