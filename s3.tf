resource "aws_s3_bucket" "b" {
  bucket = "de-op-009-bucket-lambda-trabalho_final"
  force_destroy = true

  tags = {
    Name  = "Meu bucket de testes com lambda - trabalho_final"
    Turma = "DE-OP-009-983"
  }
}

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

# Crio uma role para o lambda. 
# Lembrando: uma role é um conjunto de permissões.
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_para_o_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Crio uma permissão para o lambda poder criar log streams 
# e enviar logs para o cloudwatch
resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Aqui eu adiciono mais uma policy à role do lambda. Posso adicionar quantas forem necessárias
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py" # Para pastas, usar: source_dir 
  # source_file = "${path.module}/lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "minhaLambda"
  filename      = "lambda_function_payload.zip"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_metodo"

  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"

  runtime = "python3.9"

  environment {
    variables = {
      variavel01 = "valor01"
    }
  }
}

# Adiciono a funcionalidade do bucket s3 enviar notificações à minha função lambda.
# Os eventos que serão notificados são: Objetos criados (upload) e objetos removidos (delete).
resource "aws_s3_bucket_notification" "aws_lambda_trigger" {
  bucket = aws_s3_bucket.b.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  # O depends_on aqui garante que esse recurso "aws_s3_bucket_notification" só será criado APÓS  "aws_lambda_permission" "test", que é um "pré requisito"
  depends_on = [aws_lambda_permission.test] 
}

# Aqui eu crio um log group no cloudwatch... um log group pode ser considerado uma "pastinha" para armazenar todos os logs de uma determinada função
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

# Adiciono permissões ao meu bucket s3 para invocar (fazer trigger) à minha função lambda.
resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.b.id}"
}
