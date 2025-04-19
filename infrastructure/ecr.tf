# ecr.tf
resource "aws_ecr_repository" "backend_repo" {
  name                 = "converteasy-backend"
  image_tag_mutability = "MUTABLE"
  #force_delete         = true
  tags = {
    Project = "ConvertEasy"
  }
}
