variable "profile" {
  type        = string
  default = "default"
  description = "perfil da conta"
}

variable "region" {
  type        = string
  default = "us-east-1"
  description = "regiao aws"
}

variable "subnet_cidr_block" {
    type = list
    default = ["172.16.1.48/28", "172.16.1.64/28", "172.16.1.80/28"]
    description = "CIDR block as subnets"
}

variable "subnet_availability_zone" {
  type = list
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "AZ para as subnets"
}

variable "subnet_count" {
  type = number
  default = 3
  description = "Número de subnets a serem criadas"
}

variable "feature_name" {
  type        = string
  default = "Lambda"
  description = "Nome do bd que concede permissões de banco de dados à função Lambda"
}

variable "db_name" {
  type        = string
  default = "mydb"
  description = "db_name"
}

variable "db_engine" {
  type        = string
  default = "postgres"
  description = "engine"
}

variable "db_engine_version" {
  type        = string
  default = "12.9"
  description = "engine_version"
}

variable "db_instance_class" {
  type        = string
  default = "db.t3.micro"
  description = "instance_class"
}

variable "db_username" {
  type        = string
  default = "postgres"
  description = "Nome do usuário que você deseja criar para acessar o banco de dados."
}

variable "db_password" {
  type        = string
  default = "postgres"
  description = "Password do usuário que você deseja criar para acessar o banco de dados."
}

variable "db_port" {
  type    = number
  default = 5432
  description = "Porta do banco de dados"
}

variable "db_identifier" {
  type    = string
  default = "my-test-database"
  description = "Instance Identifier do banco de dados"
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
  description = "db_skip_final_snapshot"
}

variable "db_allocated_storage" {
  type    = number
  default = 10
  description = "allocated_storage"
}

variable "vpc_db_subnet_group" {
  type    = string
  default = "db_subnet_group"
  description = "vpc_db_subnet_group"
}

variable "protocol" {
  type    = string
  default = "tcp"
  description = "protocol"
}

variable "vpc_cidr_block" {
  type    = string
  default = "172.16.1.0/25"
  description = "o /25 indica a quantidade de IPs disponíveis para máquinas na rede"
}


variable "bucket_name" {
  type    = string
  default = "de-op-009-bucket-lambda-trabalho-final-jaffer"
  description = "Nome do Bucket"
}

variable "retention_logs" {
  type    = number
  default = 1
  description = "Retenção log"
}