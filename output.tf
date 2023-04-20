output "rds_connection_string" {
  value = aws_db_instance.mysql.endpoint
}
