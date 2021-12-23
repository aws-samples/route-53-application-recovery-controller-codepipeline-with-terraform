# ---------------------------------------------------------------------------------------------------------------------
# Code Build
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# Codebuild role

resource "aws_iam_role" "codebuild_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path = "/"
}

resource "aws_iam_policy" "codebuild_policy" {
  description = "Policy to allow codebuild to execute build spec"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.artifact_bucket_region_1.arn}/*", "${aws_s3_bucket.artifact_bucket_region_1.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild-attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}


# Codebuild project

resource "aws_codebuild_project" "codebuild" {

  name          = "codebuild-code"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type = "CODEPIPELINE"
    buildspec = <<BUILDSPEC
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 12
  build:
    commands:
      - echo Build started on `date`
      - echo Installing source NPM dependencies...
      - npm install
      - npm audit fix
  post_build:
    commands:
      - echo Build completed on `date`
artifacts:
    files: 
      - '**/*'
    name: arc-build-$(date +%Y-%m-%d)
BUILDSPEC
  }
}        
