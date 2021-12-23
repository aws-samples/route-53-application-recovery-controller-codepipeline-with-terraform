#
# This template demonstrates how to configure Amazon Route53 Application Recovery Controller Readiness Checks
# For a full description of how it works, please read
# https://aws.amazon.com/fr/blogs/aws/amazon-route-53-application-recovery-controller/
# and
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.57.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "${var.aws_region_2}"
}

#
# The Application Recovery Controller cells
#

resource "aws_route53recoveryreadiness_cell" "Cell1" {
  cell_name = "${var.stack}-Cell1-${var.aws_region_1}"
}

resource "aws_route53recoveryreadiness_cell" "Cell2" {
  cell_name = "${var.stack}-Cell2-${var.aws_region_2}"
}

#
# The Application Recovery Controller recovery groups
#

resource "aws_route53recoveryreadiness_recovery_group" "RecoveryGroup" {
  recovery_group_name = "${var.stack}-RecoveryGroup"
  cells = [aws_route53recoveryreadiness_cell.Cell1.arn, aws_route53recoveryreadiness_cell.Cell2.arn]
}

#
# The Application Recovery Controller resource set
#

# the application load balancers 

resource "aws_route53recoveryreadiness_resource_set" "ResourceSetALB" {
  resource_set_name = "${var.stack}-ResourceSet-ALB"
  resource_set_type = "AWS::ElasticLoadBalancingV2::LoadBalancer"
  
  resources {
    resource_arn = "${var.LoadBalancer1}"
    readiness_scopes = [aws_route53recoveryreadiness_cell.Cell1.arn]
  }

  resources {
    resource_arn = "${var.LoadBalancer2}"
    readiness_scopes = [aws_route53recoveryreadiness_cell.Cell2.arn]
  }

}

# the auto scaling groups 

resource "aws_route53recoveryreadiness_resource_set" "ResourceSetASG" {
  resource_set_name = "${var.stack}-ResourceSet-ASG"
  resource_set_type = "AWS::AutoScaling::AutoScalingGroup"

  resources {
    resource_arn = "${var.AutoScalingGroup1}"
    readiness_scopes = [aws_route53recoveryreadiness_cell.Cell1.arn]
  }

  resources {
    resource_arn = "${var.AutoScalingGroup2}"
    readiness_scopes = [aws_route53recoveryreadiness_cell.Cell2.arn]
  }
  
}

# the DynamoDB table

resource "aws_route53recoveryreadiness_resource_set" "ResourceSetDynamoDB" {
  resource_set_name = "${var.stack}-ResourceSet-DDB"
  resource_set_type = "AWS::DynamoDB::Table"

  resources {
    resource_arn = "${var.DynamoDBTable}"
    readiness_scopes = [aws_route53recoveryreadiness_cell.Cell1.arn]
  }

  resources {
    resource_arn = "${var.DynamoDBTable_Region2}"
    readiness_scopes = [aws_route53recoveryreadiness_cell.Cell2.arn]
  }
}

#
# The Application Recovery Controller readiness checks
#

# the application load balancers 
resource "aws_route53recoveryreadiness_readiness_check" "ReadinessCheckALB" {
  readiness_check_name = "${var.stack}-ReadinessCheck-ALB"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.ResourceSetALB.resource_set_name
}

# the auto scaling groups 
resource "aws_route53recoveryreadiness_readiness_check" "ReadinessCheckASG" {
  readiness_check_name = "${var.stack}-ReadinessCheck-ASG"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.ResourceSetASG.resource_set_name
}

# the DynamoDB table
resource "aws_route53recoveryreadiness_readiness_check" "ReadinessCheckDynamoDB" {
  readiness_check_name = "${var.stack}-ReadinessCheck-DynamoDB"
  resource_set_name    = aws_route53recoveryreadiness_resource_set.ResourceSetDynamoDB.resource_set_name
}
