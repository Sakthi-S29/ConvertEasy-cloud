#!/bin/bash
set -e

# 1. Install Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# 2. Write environment variables to /etc/environment
cat <<EOF | sudo tee /etc/environment
AWS_ACCESS_KEY_ID=${access_key}
AWS_SECRET_ACCESS_KEY=${secret_key}
AWS_SESSION_TOKEN=${session_token}
AWS_DEFAULT_REGION=us-east-1
DYNAMO_TABLE=${dynamo_table}
UPLOAD_BUCKET=${upload_bucket}
CONVERTED_BUCKET=${converted_bucket}
EOF

# 3. Source the environment for this script session (optional but useful)
export $(cat /etc/environment | xargs)

# 4. Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ${account_id}.dkr.ecr.us-east-1.amazonaws.com

# 5. Pull image and run Docker container with env
docker pull ${account_id}.dkr.ecr.us-east-1.amazonaws.com/converteasy-backend:latest

docker run -d \
  --env-file /etc/environment \
  -p 8000:8000 \
  ${account_id}.dkr.ecr.us-east-1.amazonaws.com/converteasy-backend:latest
