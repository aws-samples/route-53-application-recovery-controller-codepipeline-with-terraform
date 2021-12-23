# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "app-role" {
  name               = "${var.stack}-${var.aws_region}-app-role" 
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-policy.json

  managed_policy_arns = [aws_iam_policy.dynamodb_rw_policy.arn, "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore","arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"]
}

data "aws_iam_policy_document" "ec2-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "dynamodb_rw_policy" {
  name = "${var.stack}-${var.aws_region}-dynamodb_rw_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:*"]
        Effect   = "Allow"
        Resource = ["*"]
//        Resource = ["${var.DynamoDBTable}"]
      },
    ]
  })
}
