# Cria uma Role para a Lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"] 
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Cria uma função Lambda
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function_payload.zip"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
}

# Adiciona permissão à Lambda para acessar o RDS
resource "aws_lambda_permission" "rds_lambda_permission" {
  statement_id  = "AllowExecutionFromLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "rds.amazonaws.com"
}

# Cria um Bucket S3
resource "aws_s3_bucket" "my_bucket" {
  bucket = "de-op-009-bucket-lambda-trabalho-final"
  force_destroy = true

    tags = {
    Name  = "Meu bucket de testes com lambda - trabalho-final"
    Turma = "DE-OP-009-983"
  }
}

# Adiciona permissão à Lambda para acessar o S3
resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.my_bucket.arn}"
}

# Adiciona a função Lambda à lista de eventos S3
resource "aws_s3_bucket_notification" "my_s3_bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "input/"
  }

  depends_on = [aws_lambda_permission.s3_lambda_permission]
}

# Concede permissões de banco de dados à função Lambda
resource "aws_db_instance_role_association" "my_rds_association" {
  db_instance_identifier = aws_db_instance.my_rds_instance.identifier
  role_arn               = aws_iam_role.lambda_role.arn
  feature_name           = var.feature_name
}
