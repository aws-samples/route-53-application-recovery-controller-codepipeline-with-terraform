#!/bin/bash

# --------------------------------------------------------------
# AFTER deploying the TicTacToe application
# Extract values from "out.json" file
# --------------------------------------------------------------

terraform output -state=../2_app_stack/region-1/terraform.tfstate -json > tf_output_region1.json
terraform output -state=../2_app_stack/region-2/terraform.tfstate -json > tf_output_region2.json
terraform output -state=../1_database_stack/terraform.tfstate     -json > tf_output_database.json

# Get ARNs of the Load Balancers
export TF_VAR_LoadBalancer1=$(cat tf_output_region1.json | jq .\"alb-arn\".value -r)
export TF_VAR_LoadBalancer2=$(cat tf_output_region2.json | jq .\"alb-arn\".value -r)

# Get ARNs of the Auto Scaling Groups
export TF_VAR_AutoScalingGroup1=$(cat tf_output_region1.json | jq .\"asg-arn\".value -r)
export TF_VAR_AutoScalingGroup2=$(cat tf_output_region2.json | jq .\"asg-arn\".value -r)

# Get ARNs of the DynamoDB table
export TF_VAR_DynamoDBTable=$(cat tf_output_database.json | jq .\"dynamodb-arn\".value -r)

# Get ARNs of the DynamoDB table in Region 2
export TF_VAR_DynamoDBTable_Region2=$(echo "${TF_VAR_DynamoDBTable/$TF_VAR_aws_region_1/$TF_VAR_aws_region_2}")

# Get DNS NAME of the Load Balancers
export TF_VAR_LoadBalancerDNSNameEast=$(cat tf_output_region1.json | jq .\"alb-dns-name\".value -r)
export TF_VAR_LoadBalancerDNSNameWest=$(cat tf_output_region2.json | jq .\"alb-dns-name\".value -r)

# Get Hosted Zone ID of the Load Balancers
export TF_VAR_LoadBalancerHostedZoneEast=$(cat tf_output_region1.json | jq .\"alb-zone-id\".value -r)
export TF_VAR_LoadBalancerHostedZoneWest=$(cat tf_output_region2.json | jq .\"alb-zone-id\".value -r)
