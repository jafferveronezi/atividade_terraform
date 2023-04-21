# Cria um grupo de segurança contendo regras de entrada e saída de rede. 
# Idealmente, apenas abra o que for necessário e preciso.
resource "aws_security_group" "allow_db" {
  name        = "permite_conexao_rds"
  description = "Grupo de seguranca para permitir conexao ao db"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "Porta de conexao ao Mysql"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block] #["0.0.0.0/0"] aws_vpc.dev-vpc.cidr_blocks
  }

  egress {
    description = "HTTPS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block] # ["0.0.0.0/0"] aws_vpc.dev-vpc.cidr_blocks
  }

  tags = {
    Name = "DE-OP-009-trabalho-final"
  }
}

# Cria uma instância de RDS
resource "aws_db_instance" "my_rds_instance" {
  allocated_storage = 10
  db_name           = "mydb"
  engine            = "postgres"
  engine_version    = "12.9"
  instance_class    = "db.t3.micro"
  username          = "username" # Nome do usuário "master"
  password          = "password" # Senha do usuário master
  port              = 5432
  # Parâmetro que indica se o DB vai ser acessível publicamente ou não.
  # Se quiser adicionar isso, preciso de um internet gateway na minha subnet. Em outras palavras, preciso permitir acesso "de fora" da aws.
  # publicly_accessible    = true

  # Parâmetro que indica se queremos ter um cluster RDS que seja multi az. 
  # Lembrando, paga-se a mais por isso, mas para ambientes produtivos é essencial.
  # multi_az               = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.allow_db.id]
}

# Cria uma instância RDS
# resource "aws_db_instance" "my_rds_instance" {
#   allocated_storage    = 10
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   db_name              = "my_rds_instance"
#   username             = "admin"
#   password             = "admin123"
#   parameter_group_name = "default.mysql5.7"
#   port                 = 3306

#   skip_final_snapshot  = true
#   db_subnet_group_name  = aws_db_subnet_group.db-subnet.name
#   vpc_security_group_ids = [aws_security_group.allow_db.id]
# }
