# Basic Configuration
variable "connector_name" {
  type        = string
  description = "Name of the MSK Connect connector"
}

variable "env" {
  type        = string
  description = "Environment (dev, qa, prod)"
}

variable "region" {
  type        = string
  description = "AWS region (e.g., us-east-1)"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "kafkaconnect_version" {
  type        = string
  default     = "2.7.1"
  description = "Kafka Connect version"
}

# Connector Type and Permissions
variable "connector_type" {
  type        = string
  description = "Type of connector: 'source' or 'sink'"
  validation {
    condition     = contains(["source", "sink"], var.connector_type)
    error_message = "connector_type must be 'source' or 'sink'"
  }
}

variable "kafka_topics_read" {
  type        = list(string)
  default     = []
  description = "Kafka topics this connector can READ (for Sink connectors)"
}

variable "kafka_topics_write" {
  type        = list(string)
  default     = []
  description = "Kafka topics this connector can WRITE (for Source connectors)"
}

# Network Configuration
variable "vpc_id" {
  type        = string
  description = "VPC ID for the connector"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs where connector will run"
}

# MSK Configuration
variable "msk_cluster_arn" {
  type        = string
  description = "ARN of the MSK cluster"
}

variable "msk_bootstrap_servers" {
  type        = string
  description = "MSK bootstrap servers endpoint"
}

variable "msk_authentication_type" {
  type        = string
  default     = "IAM"
  description = "MSK authentication type: IAM or NONE"
  validation {
    condition     = contains(["IAM", "NONE"], var.msk_authentication_type)
    error_message = "msk_authentication_type must be 'IAM' or 'NONE'"
  }
}

variable "msk_kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for MSK cluster encryption"
}

variable "rds_secret_arn" {
  type        = string
  default     = null
  description = "ARN of Secrets Manager secret containing RDS credentials"
}

# S3 Configuration (for Sink Connectors)
variable "s3_sink_bucket_arn" {
  type        = string
  default     = null
  description = "ARN of S3 bucket for Sink connectors"
}

variable "s3_kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for S3 bucket encryption"
}

variable "secrets_kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN for Secrets Manager (if using custom KMS key)"
}

# Plugin Configuration
variable "custom_plugin_arn" {
  type        = string
  description = "ARN of the custom plugin (Debezium or S3 Sink)"
}

variable "custom_plugin_revision" {
  type        = number
  default     = 1
  description = "Revision number of the custom plugin"
}

variable "custom_plugin_bucket_arn" {
  type        = string
  description = "ARN of S3 bucket containing the plugin"
}

# Connector Configuration
variable "connector_configuration" {
  type        = map(string)
  description = "Connector-specific configuration properties"
}

# Autoscaling Configuration
variable "autoscaling_mcu_count" {
  type        = number
  default     = 1
  description = "Number of MCU (MSK Connect Units) per worker"
  validation {
    condition     = contains([1, 2, 4, 8], var.autoscaling_mcu_count)
    error_message = "autoscaling_mcu_count must be 1, 2, 4, or 8"
  }
}

variable "autoscaling_min_worker_count" {
  type        = number
  default     = 1
  description = "Minimum number of workers"
  validation {
    condition     = var.autoscaling_min_worker_count >= 1 && var.autoscaling_min_worker_count <= 10
    error_message = "autoscaling_min_worker_count must be between 1 and 10"
  }
}

variable "autoscaling_max_worker_count" {
  type        = number
  default     = 2
  description = "Maximum number of workers"
  validation {
    condition     = var.autoscaling_max_worker_count >= 1 && var.autoscaling_max_worker_count <= 10
    error_message = "autoscaling_max_worker_count must be between 1 and 10"
  }
}

variable "autoscaling_scale_in_cpu" {
  type        = number
  default     = 20
  description = "CPU utilization percentage to trigger scale in"
  validation {
    condition     = var.autoscaling_scale_in_cpu >= 1 && var.autoscaling_scale_in_cpu <= 100
    error_message = "autoscaling_scale_in_cpu must be between 1 and 100"
  }
}

variable "autoscaling_scale_out_cpu" {
  type        = number
  default     = 80
  description = "CPU utilization percentage to trigger scale out"
  validation {
    condition     = var.autoscaling_scale_out_cpu >= 1 && var.autoscaling_scale_out_cpu <= 100
    error_message = "autoscaling_scale_out_cpu must be between 1 and 100"
  }
}

# Logging Configuration
variable "log_retention_in_days" {
  type        = number
  default     = 7
  description = "CloudWatch Logs retention in days"
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_in_days)
    error_message = "log_retention_in_days must be a valid CloudWatch retention period"
  }
}

# Tags
variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags for all resources"
}
