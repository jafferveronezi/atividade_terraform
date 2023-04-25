terraform init
terraform apply -auto-approve

BUCKET_NAME=$(terraform output -raw bucket_name)
BUCKET_RDS_CONNECTION=$(terraform output -raw rds_connection_string)
BUCKET_LAMBDA_NAME=$(terraform output -raw lambda_name)

echo "Nome da Lambda $BUCKET_LAMBDA_NAME"

echo "Sua conexão RDS é $BUCKET_RDS_CONNECTION"