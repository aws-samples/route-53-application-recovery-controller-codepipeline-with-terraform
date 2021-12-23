# Codepipeline role

resource "aws_iam_role" "codepipeline_role" {
  depends_on = [aws_s3_bucket.artifact_bucket_region_1, aws_s3_bucket.artifact_bucket_region_2]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  description = "Policy to allow codepipeline to execute"
  
  depends_on = [aws_s3_bucket.artifact_bucket_region_1, aws_s3_bucket.artifact_bucket_region_2]
  
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.artifact_bucket_region_1.arn}/*", 
                    "${aws_s3_bucket.artifact_bucket_region_1.arn}", 
                    "${aws_s3_bucket.artifact_bucket_region_2.arn}/*", 
                    "${aws_s3_bucket.artifact_bucket_region_2.arn}", 
                    "${var.source_code_bucket_arn}/*",
                    "${var.source_code_bucket_arn}"]
    },
    {
      "Action" : [
        "iam:PassRole",
        "codebuild:StartBuild", 
        "codebuild:BatchGetBuilds"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "kms:*"
      ],
      "Resource": "*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "codedeploy:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  policy_arn = aws_iam_policy.codepipeline_policy.arn
  role       = aws_iam_role.codepipeline_role.name
  
  depends_on = [aws_iam_policy.codepipeline_policy, aws_iam_role.codepipeline_role]
  
}

