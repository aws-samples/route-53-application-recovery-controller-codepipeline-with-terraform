# ---------------------------------------------------------------------------------------------------------------------
# DynamoDB Global Table
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_dynamodb_table" "dynamodb-global" {
  name             = "nodejs-tutorial"
  hash_key         = "email"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "email"
    type = "S"
  }

  replica {
    region_name = "${var.aws_region_2}"
  }

  
  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
  
}

output "dynamodb-arn" {
  value = aws_dynamodb_table.dynamodb-global.arn
}

