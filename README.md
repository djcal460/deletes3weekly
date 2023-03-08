# Lambda Function that deletes all objects from S3 Bucket

This terraform is set to create a lambda function and s3 bucket. The lambda function deletes all objects from the s3 bucket every Sunday at 12pm and publishes a notification via SNS to the email address declared in terraform.tfvars. 

## Installation

Input AWS credentials into terraform.tfvars as well as the notification email. Run the below commands to create the lambda function and S3 Bucket

```bash
terraform init
terraform plan
terraform apply
```
Confirm your subscription to SNS in your email inbox. 

## Usage
Connect to awscli using your credentials and invoke the function once to initiate the EventBridge trigger.
```bash
aws lambda invoke --function-name "s3-automation" --log-type Tail output.txt
```