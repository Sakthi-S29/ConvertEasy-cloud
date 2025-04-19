variable "aws_access_key" {
  type        = string
  description = "Temporary access key from Learner Lab"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "Temporary secret key from Learner Lab"
  sensitive   = true
}

variable "aws_session_token" {
  type        = string
  description = "Temporary session token from Learner Lab"
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}
