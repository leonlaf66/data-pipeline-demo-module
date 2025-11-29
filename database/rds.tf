resource "aws_db_parameter_group" "cdc" {
  name   = "${var.app_name}-pg-cdc-${var.env}"
  family = var.db_parameter_group_family

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
  
  parameter {
    name  = "wal_sender_timeout"
    value = "0"
  }

  tags = var.common_tags
}

resource "aws_db_instance" "this" {
  identifier = "${var.app_name}-source-db-${var.env}"
  
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  
  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.cdc.name
  publicly_accessible    = false
  multi_az               = var.db_multi_az

  storage_encrypted = true
  kms_key_id       = aws_kms_key.database.arn

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.app_name}-source-db-${var.env}-final-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  backup_retention_period   = var.backup_retention_period
  backup_window            = var.backup_window
  maintenance_window       = var.maintenance_window
  deletion_protection      = var.deletion_protection
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-source-db-${var.env}"
      CDC  = "enabled"
    }
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}


resource "aws_db_subnet_group" "this" {
  name       = "${var.app_name}-db-subnet-group-${var.env}"
  subnet_ids = var.db_subnet_ids
  
  description = "Subnet group for ${var.app_name} RDS instance (${var.env})"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-db-subnet-group-${var.env}"
    }
  )
}