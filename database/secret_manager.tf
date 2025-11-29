resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret" "master" {
  name                    = "${var.app_name}-rds-master-creds-${var.env}"
  description             = "Master DB credentials for ${var.app_name} RDS (${var.env})"
  recovery_window_in_days = 7
  kms_key_id             = aws_kms_key.database.arn
  
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.app_name}-rds-master-creds"
      Environment = var.env
    }
  )
}

resource "aws_secretsmanager_secret_version" "master" {
  secret_id     = aws_secretsmanager_secret.master.id
  secret_string = jsonencode({
    username            = var.db_username
    password            = random_password.master.result
    engine              = "postgres"
    host                = aws_db_instance.this.address
    port                = aws_db_instance.this.port
    dbname              = var.db_name
    dbInstanceIdentifier = aws_db_instance.this.id
  })
}
