# KMS Key Outputs
output "kms_key_arn" {
  description = "The ARN of the KMS key used for database encryption"
  value       = aws_kms_key.database.arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for database encryption"
  value       = aws_kms_key.database.key_id
}

# RDS Instance Outputs
output "endpoint" {
  description = "The connection endpoint in address:port format"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_resource_id" {
  description = "The RDS Resource ID (used for DMS source endpoint)"
  value       = aws_db_instance.this.resource_id
}

output "db_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

# Security Outputs
output "security_group_id" {
  description = "The ID of the Security Group attached to the RDS instance"
  value       = aws_security_group.rds.id
}

# Secrets Manager Outputs
output "master_secret_arn" {
  description = "ARN of the Secrets Manager secret containing master DB credentials"
  value       = aws_secretsmanager_secret.master.arn
  sensitive   = true
}

output "master_secret_name" {
  description = "Name of the Secrets Manager secret containing master DB credentials"
  value       = aws_secretsmanager_secret.master.name
}

# Configuration Outputs (for DMS)
output "parameter_group_name" {
  description = "The DB parameter group name (CDC enabled)"
  value       = aws_db_parameter_group.cdc.name
}

output "engine" {
  description = "The database engine"
  value       = aws_db_instance.this.engine
}

output "engine_version" {
  description = "The database engine version"
  value       = aws_db_instance.this.engine_version_actual
}
