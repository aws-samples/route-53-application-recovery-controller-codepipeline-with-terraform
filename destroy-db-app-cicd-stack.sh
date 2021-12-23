#!/bin/bash

HOME=$PWD

#-----------------------------
# Set Terraform variables
#-----------------------------
. set-terraform-variables.sh

#----------------------------------------------------------------
# Destroy Route 53 ARC components
#----------------------------------------------------------------
echo " "
echo "==> Destroy Route 53 ARC components"
echo " "
cd $HOME/4_arc_terraform

. set-arc-system-variables.sh

terraform init

terraform destroy -auto-approve

#----------------------------------------------------------------
# Destroy Multi-region AWS CodePipeline, CodeBuild and CodeDeploy
#----------------------------------------------------------------
echo " "
echo "==> Destroy Multi-region AWS CodePipeline, CodeBuild and CodeDeploy"
echo " "

# Get the Name and ARN of the S3 Bucket that stores the source code

cd $HOME/0_code_to_s3
terraform output -state=terraform.tfstate -json > tf_output_source_code_bucket.json
export TF_VAR_source_code_bucket_name=$(cat tf_output_source_code_bucket.json | jq .\"source_code_bucket\".value.bucket -r)
export TF_VAR_source_code_bucket_arn=$(cat tf_output_source_code_bucket.json | jq .\"source_code_bucket\".value.arn -r)

# Destroy
cd $HOME/3_ci_cd

terraform destroy -auto-approve

#--------------------------------
# Destroy App Stack in Region 2
#--------------------------------
echo " "
echo "==> Destroy App Stack in Region 2"
echo " "
cd $HOME/2_app_stack/region-2/

terraform destroy -auto-approve

#--------------------------------
# Destroy App Stack in Region 1
#--------------------------------
echo " "
echo "==> Destroy App Stack in Region 1"
echo " "
cd $HOME/2_app_stack/region-1/

terraform destroy -auto-approve

#----------------------------------------------------------
# Destroy DB Stack: DynamoDB global table in 2 regions
#----------------------------------------------------------
echo " "
echo "==> Destroy DB Stack: DynamoDB global table in 2 regions"
echo " "

cd $HOME/1_database_stack

terraform destroy -auto-approve

#----------------------------------------------------------
# Destroy S3 Bucket to store Source Code
#----------------------------------------------------------
echo " "
echo "==> Destroy S3 Bucket to store Source Code"
echo " "

cd $HOME/0_code_to_s3

terraform destroy -auto-approve
