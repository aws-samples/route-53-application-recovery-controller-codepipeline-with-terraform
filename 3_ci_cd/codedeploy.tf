# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
  name = "codedeploy-service-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = "${aws_iam_role.codedeploy_service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# create a CodeDeploy application
resource "aws_codedeploy_app" "main" {
  name = "ARC_App"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "main" {
  app_name              = "${aws_codedeploy_app.main.name}"
  deployment_group_name = "ARC_Deployment_Group"
  service_role_arn      = "${aws_iam_role.codedeploy_service.arn}"

  deployment_config_name = "CodeDeployDefault.OneAtATime" # AWS defined deployment config
  
  autoscaling_groups = ["${var.stack}-asg"]
  
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  
  load_balancer_info {
    target_group_info {
      name = "${var.stack}-tgrp"
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "ARC_App"
    }
  }

  # trigger a rollback on deployment failure event
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
    ]
  }
}


# create a CodeDeploy application
resource "aws_codedeploy_app" "app_region_2" {
  provider = aws.region-2
  name = "ARC_App"
}


# create a deployment group
resource "aws_codedeploy_deployment_group" "deployment_group_region_2" {
  provider = aws.region-2
  
  app_name              = "${aws_codedeploy_app.app_region_2.name}"
  deployment_group_name = "ARC_Deployment_Group"
  service_role_arn      = "${aws_iam_role.codedeploy_service.arn}"

  deployment_config_name = "CodeDeployDefault.OneAtATime" # AWS defined deployment config
  
  autoscaling_groups = ["${var.stack}-asg"]
  
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  
  
  load_balancer_info {
    target_group_info {
      name = "${var.stack}-tgrp"
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "ARC_App"
    }
  }

  # trigger a rollback on deployment failure event
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
    ]
  }
}
