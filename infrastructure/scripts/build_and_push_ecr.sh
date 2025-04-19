#!/bin/bash
set -e

# --------- CONFIGURE THESE ---------
IMAGE_NAME="converteasy-backend"
REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME"

# --------- AUTH ---------
echo "[*] Logging in to ECR..."
aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin $REPO_URI

# --------- BUILD & PUSH ---------
echo "[*] Building and pushing Docker image for linux/amd64..."
docker buildx build \
  --platform linux/amd64 \
  -t $REPO_URI:latest \
  --push ../backend

echo "[✓] Docker image pushed to $REPO_URI"

# --------- TERRAFORM APPLY ---------
terraform apply -auto-approve -target=aws_instance.backend
