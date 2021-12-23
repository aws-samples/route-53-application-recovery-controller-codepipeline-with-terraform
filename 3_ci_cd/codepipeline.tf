
# ---------------------------------------------------------------------------------------------------------------------
# Code Pipeline
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "artifact_bucket_region_1" {
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3_region_1_public_block" {
  bucket = aws_s3_bucket.artifact_bucket_region_1.id

  block_public_acls   = true
  block_public_policy = true
}


resource "aws_s3_bucket" "artifact_bucket_region_2" {
  provider = aws.region-2

  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3_region_2_public_block" {
  provider = aws.region-2
  
  bucket = aws_s3_bucket.artifact_bucket_region_2.id

  block_public_acls   = true
  block_public_policy = true
}


# CodePipeline 

resource "aws_codepipeline" "pipeline" {

  name     = "ARC-Pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  
  depends_on = [aws_iam_role_policy_attachment.codepipeline-attach]

  artifact_store {
    location = aws_s3_bucket.artifact_bucket_region_1.bucket
    type     = "S3"
    region   = "${var.aws_region_1}"
  }

  artifact_store {
    location = aws_s3_bucket.artifact_bucket_region_2.bucket
    type     = "S3"
    region   = "${var.aws_region_2}"
  }


  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "S3"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        S3Bucket = "${var.source_code_bucket_name}"
        S3ObjectKey = "nodejs-sample-app.zip"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
    }
  }
  
  stage {
    name = "Deploy-to-Region-1"
    action {
      region          = "${var.aws_region_1}"
      name            = "Deploy-to-Region-1"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      provider        = "CodeDeploy"
      run_order       = 1
      input_artifacts = ["BuildOutput"]

      configuration = {
        ApplicationName      = aws_codedeploy_app.main.name
        DeploymentGroupName  = aws_codedeploy_deployment_group.main.deployment_group_name
      }
    }
  }


  stage {
    name = "Manual-Approval"
  
    action {
      category = "Approval"
      name     = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
  
      configuration = {
        CustomData = "Please make sure that the app was successfully deployed in the first Region before continuing."
        ExternalEntityLink = "https://reinvent.awsevents.com/"
      }
    }
  }


  stage {
    name = "Deploy-to-Region-2"
    action {
      region          = "${var.aws_region_2}"
      name            = "Deploy-to-Region-2"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      provider        = "CodeDeploy"
      run_order       = 1
      input_artifacts = ["BuildOutput"]

      configuration = {
        ApplicationName      = aws_codedeploy_app.app_region_2.name
        DeploymentGroupName  = aws_codedeploy_deployment_group.deployment_group_region_2.deployment_group_name
      }
    }
  }  



}

output "pipeline_url" {
  value = "https://console.aws.amazon.com/codepipeline/home?region=${var.aws_region_1}#/view/${aws_codepipeline.pipeline.id}"
}

output "s3_bucket_region_1" {
  value = aws_s3_bucket.artifact_bucket_region_1
}

output "s3_bucket_region_2" {
  value = aws_s3_bucket.artifact_bucket_region_2
}


output "code_deploy" {
  value = aws_codedeploy_deployment_group.main
}
