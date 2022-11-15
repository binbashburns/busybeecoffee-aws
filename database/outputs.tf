output "hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "endpoint" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "database-name" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.name
  sensitive   = true
}

output "dbAsub" {
  value = aws_subnet.dbA.id
}

output "dbBsub" {
  value = aws_subnet.dbB.id
}

output "dbCsub" {
  value = aws_subnet.dbC.id
}
