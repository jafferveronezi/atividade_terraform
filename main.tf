data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Cria uma Role para a Lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"] 
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Necessária para executar funções do AWS Lambda com recursos VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
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

  environment {
    variables = {
      DB_NAME     = aws_db_instance.my_rds_instance.db_name
      DB_USER     = aws_db_instance.my_rds_instance.username
      DB_PASSWORD = aws_db_instance.my_rds_instance.password
      DB_HOST     = aws_db_instance.my_rds_instance.endpoint
      DB_PORT     = aws_db_instance.my_rds_instance.port
    }
  }

  vpc_config {
    #verificar nomes
    subnet_ids         = [aws_subnet.private-subnet[0].id, aws_subnet.private-subnet[1].id]
    security_group_ids = [aws_security_group.allow_db.id]
  }

  depends_on = [aws_iam_policy.lambda_s3_policy]
}

# Cria um Bucket S3
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  force_destroy = true

    tags = {
    Name  = "Meu bucket de testes com lambda - trabalho-final"
    Turma = "DE-OP-009-983"
  }
}

# Cria uma política para conceder acesso ao S3
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.my_bucket.arn}",
      "${aws_s3_bucket.my_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name   = "lambda_s3_policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

# Anexa a política de acesso ao S3 à função IAM do Lambda
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Adiciona permissão à Lambda para acessar o S3
resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.my_bucket.arn}"
}

# Aqui eu crio um log group no cloudwatch... um log group pode ser considerado uma "pastinha" para armazenar todos os logs de uma determinada função
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.my_lambda.function_name}"
  retention_in_days = var.retention_logs
  lifecycle {
    prevent_destroy = false
  }
}

# Adiciona a função Lambda à lista de eventos S3
resource "aws_s3_bucket_notification" "my_s3_bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_lambda_permission.s3_lambda_permission]
}
