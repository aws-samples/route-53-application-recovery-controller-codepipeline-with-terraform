#!/bin/bash

#-----------------------------
# Set Terraform variables
#-----------------------------
export TF_VAR_aws_region_1="us-east-2"
export TF_VAR_aws_region_2="us-west-2"
export TF_VAR_stack="tf-arc"
export TF_VAR_aws_profile="default"
export TF_VAR_DNSHostedZone=Z16ABCDEFGA9Z
export TF_VAR_DNSDomainName=gtphonehome.com