# Cria um grupo de segurança contendo regras de entrada e saída de rede. 
# Idealmente, apenas abra o que for necessário e preciso.
resource "aws_security_group" "allow_db" {
  name        = "permite_conexao_rds"
  description = "Grupo de seguranca para permitir conexao ao db"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "Porta de conexao ao Mysql"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = var.protocol
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block] #["0.0.0.0/0"] aws_vpc.dev-vpc.cidr_blocks
  }

  egress {
    description = "HTTPS"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = var.protocol
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block] # ["0.0.0.0/0"] aws_vpc.dev-vpc.cidr_blocks
  }

  tags = {
    Name = "DE-OP-009-trabalho-final"
  }
}

# Cria uma instância de RDS
resource "aws_db_instance" "my_rds_instance" {
  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  username          = var.db_username
  password          = var.db_password
  port              = var.db_port
  identifier        = var.db_identifier
  # Parâmetro que indica se o DB vai ser acessível publicamente ou não.
  # Se quiser adicionar isso, preciso de um internet gateway na minha subnet. Em outras palavras, preciso permitir acesso "de fora" da aws.
  #publicly_accessible    = true

  # Parâmetro que indica se queremos ter um cluster RDS que seja multi az. 
  # Lembrando, paga-se a mais por isso, mas para ambientes produtivos é essencial.
  # multi_az               = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [aws_security_group.allow_db.id]
}
