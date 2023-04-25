output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}


output "lambda_name" {
  value = aws_lambda_function.my_lambda.function_name
}

output "rds_connection_string" {
  value = aws_db_instance.my_rds_instance.endpoint
}