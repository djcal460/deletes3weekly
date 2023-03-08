
import boto3
import random
import string
import json
from botocore.exceptions import ClientError
import logging
import datetime

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
client = boto3.client('events')
lambda_client = boto3.client('lambda')
iam_client = boto3.client('iam')
sns_client = boto3.client('sns')


def lambda_handler(event, context):
    
    add_schedule()

    current_time = datetime.datetime.now().time()
    name = context.function_name
    logger.info("Your cron function " + name + " ran at " + str(current_time))
    
    s3 = boto3.resource('s3')
    bucket = s3.Bucket('my-report-bucket-1086')
    bucket.objects.all().delete()
    
    topic = sns_client.create_topic(Name='notify-team')
    topic_arn = topic['TopicArn']
    
    sub = "S3 Bucket: my-report-bucket-1086 has been emptied"
    msg = "Your S3 Bucket my-report-bucket-1086 has been emptied by a lambda function"
    response = sns_client.publish(TopicArn=topic_arn,Message=msg,Subject=sub)

    return response

def add_schedule():
    response = client.list_rules(NamePrefix='RunEverySunday')
    if response['Rules'] == []:
        iamrole = iam_client.get_role(RoleName='lambda_role')
        iamrolearn = iamrole['Role']['Arn']
        lambdafun = lambda_client.get_function(FunctionName='s3-automation')
        lambdaarn = lambdafun['Configuration']['FunctionArn']
        rule = client.put_rule(Name="RunEverySunday",ScheduleExpression="cron(0 12 ? * SUN *)",State="ENABLED",RoleArn=iamrolearn)
        lambda_client.add_permission(FunctionName=lambdaarn,StatementId="RunEverySunday",Action="lambda:InvokeFunction",Principal="events.amazonaws.com",SourceArn= rule["RuleArn"])
        client.put_targets(Rule="RunEverySunday",Targets=[{"Id": "s3-automation","Arn": lambdaarn}])




