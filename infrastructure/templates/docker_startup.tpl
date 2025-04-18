#!/bin/bash
set -e

sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

echo "Creating .env..."
cat <<EOF > /home/ec2-user/.env
RDS_HOST=${db_host}
RDS_USER=${db_user}
RDS_PASS=${db_pass}
AWS_ACCESS_KEY_ID=${access_key}
AWS_SECRET_ACCESS_KEY=${secret_key}
AWS_SESSION_TOKEN=${session_token}
EOF

docker pull sakthisharan/converteasy-backend:latest
docker run -d --env-file /home/ec2-user/.env -p 8000:8000 sakthisharan/converteasy-backend:latest
