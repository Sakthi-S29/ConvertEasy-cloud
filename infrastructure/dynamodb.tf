resource "aws_dynamodb_table" "conversion_logs" {
  name           = "converteasy-logs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "ConvertEasy"
  }
}
