variable "app_name" {
  type        = string
  description = "The name of the application or service"
}

variable "env" {
  type        = string
  description = "The deployment environment (e.g., 'dev', 'qa', 'prod')"
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "account_id" {
  type        = string
  description = "The AWS Account ID"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to resources"
}

# Network Configuration

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the RDS instance will be deployed"
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DB subnet group (must be in at least 2 different AZs)"
}

variable "allowed_ingress_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to access the database (e.g., VPC CIDR)"
}

variable "allowed_ingress_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security group IDs allowed to access the database (e.g., DMS, Lambda)"
}

# Database Configuration

variable "db_name" {
  type        = string
  default     = "kraken_db"
  description = "The name of the database to create when the DB instance is created"
}

variable "db_engine_version" {
  type        = string
  default     = "14.7"
  description = "PostgreSQL engine version"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "The instance type of the RDS instance"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "The allocated storage in gigabytes"
}

variable "db_max_allocated_storage" {
  type        = number
  default     = 100
  description = "The upper limit to which Amazon RDS can automatically scale the storage"
}

variable "db_storage_type" {
  type        = string
  default     = "gp3"
  description = "The storage type (gp2, gp3, io1)"
}

variable "db_parameter_group_family" {
  type        = string
  default     = "postgres14"
  description = "The family of the DB parameter group"
}

variable "db_multi_az" {
  type        = bool
  default     = false
  description = "Specifies if the RDS instance is multi-AZ"
}

# Credentials

variable "db_username" {
  type        = string
  default     = "postgres"
  description = "Username for the master DB user"
}

# Backup & Maintenance

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Determines whether a final DB snapshot is created before deletion (set to false in prod)"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "The days to retain backups for"
}

variable "backup_window" {
  type        = string
  default     = "03:00-04:00"
  description = "The daily time range during which automated backups are created (UTC)"
}

variable "maintenance_window" {
  type        = string
  default     = "sun:04:00-sun:05:00"
  description = "The window to perform maintenance in (UTC)"
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "If the DB instance should have deletion protection enabled (set to true in prod)"
}
