#!/bin/bash

HOME2=$PWD

#-----------------------------
# Set Terraform variables
#-----------------------------
. set-terraform-variables.sh

#----------------------------------------------------------
# Create S3 Bucket to store Source Code
#----------------------------------------------------------
echo " "
echo "==> Create S3 Bucket to store Source Code"
echo " "

cd $HOME2/0_code_to_s3

terraform init

terraform apply -auto-approve

#----------------------------------------------------------
# Push Code to S3 bucket
#----------------------------------------------------------

echo " "
echo "==> Push Code to S3 bucket"
echo " "

terraform output -state=terraform.tfstate -json > tf_output_source_code_bucket.json
export TF_VAR_source_code_bucket_name=$(cat tf_output_source_code_bucket.json | jq .\"source_code_bucket\".value.bucket -r)
export TF_VAR_source_code_bucket_arn=$(cat tf_output_source_code_bucket.json | jq .\"source_code_bucket\".value.arn -r)

cd $HOME2/nodejs-sample-app/

zip -r nodejs-sample-app.zip . -x *.git* node_modules/\*

mv nodejs-sample-app.zip $HOME2/

cd $HOME2/
aws s3 cp nodejs-sample-app.zip s3://$TF_VAR_source_code_bucket_name/nodejs-sample-app.zip

#----------------------------------------------------------
# Create DB Stack: DynamoDB global table in 2 regions
#----------------------------------------------------------
echo " "
echo "==> Create DB Stack: DynamoDB global table in 2 regions"
echo " "

cd $HOME2/1_database_stack

terraform init 

terraform apply -auto-approve

#--------------------------------
# Create App Stack in Region 1
#--------------------------------
echo " "
echo "==> Create App Stack in Region 1"
echo " "
cd $HOME2/2_app_stack/region-1/

terraform init

terraform apply -auto-approve

#--------------------------------
# Create App Stack in Region 2
#--------------------------------
echo " "
echo "==> Create App Stack in Region 2"
echo " "
cd $HOME2/2_app_stack/region-2/

terraform init

terraform apply -auto-approve

#----------------------------------------------------------------
# Create Multi-region AWS CodePipeline, CodeBuild and CodeDeploy
#----------------------------------------------------------------
echo " "
echo "==> Create Multi-region AWS CodePipeline, CodeBuild and CodeDeploy"
echo " "
cd $HOME2/3_ci_cd

terraform init

terraform apply -auto-approve

#----------------------------------------------------------------
# Create Route 53 ARC components
#----------------------------------------------------------------

echo " "
echo "==> Create Route 53 ARC components"
echo " "
cd $HOME2/4_arc_terraform

. set-arc-system-variables.sh

terraform init

terraform apply -auto-approve
