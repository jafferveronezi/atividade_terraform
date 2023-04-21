import json
import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    rds = boto3.client('rds')
    
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    s3_object = s3.get_object(Bucket=bucket_name, Key=object_key)
    content = s3_object['Body'].read().decode('utf-8')
    
    response = rds.execute_statement(
        database=os.environ['DB_NAME'],
        resourceArn=os.environ['DB_ARN'],
        secretArn=os.environ['DB_SECRET'],
        sql='INSERT INTO my_table (content) VALUES (?)',
        parameters=[
            {'stringValue': content}
        ]
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Data inserted successfully')
    }