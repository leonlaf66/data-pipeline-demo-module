# Kafka Connection Configuration

variable "bootstrap_servers" {
  type        = string
  description = "Kafka bootstrap servers endpoint (from MSK NLB)"
}

variable "kafka_admin_username" {
  type        = string
  description = "Admin username for Kafka operations (must have Topic/ACL management permissions)"
  default     = "admin"
}

variable "kafka_admin_password" {
  type        = string
  description = "Admin password from Secrets Manager (SCRAM-SHA-512)"
  sensitive   = true
}

variable "skip_tls_verify" {
  type        = bool
  description = "Skip TLS certificate verification (set to true for dev, false for prod)"
  default     = false
}

# MSK Cluster Information (for reference/tagging)

variable "msk_cluster_arn" {
  type        = string
  description = "ARN of the MSK cluster (used for tagging and reference)"
}

variable "msk_cluster_name" {
  type        = string
  description = "Name of the MSK cluster (used for naming conventions)"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to resources"
}

# Topics Configuration

variable "topics" {
  description = "List of Kafka topics to create with their configurations"
  type = list(object({
    name               = string
    replication_factor = number
    partitions         = number
    config             = map(string)
  }))
  default = []
  
  validation {
    condition = alltrue([
      for t in var.topics : t.replication_factor >= 1 && t.replication_factor <= 3
    ])
    error_message = "replication_factor must be between 1 and 3"
  }
  
  validation {
    condition = alltrue([
      for t in var.topics : t.partitions >= 1 && t.partitions <= 100
    ])
    error_message = "partitions must be between 1 and 100"
  }
}

# ACLs Configuration

variable "user_acls" {
  description = <<-EOT
    Map of SCRAM usernames to their list of ACL permissions.
    Key: username (must match SCRAM user created in MSK module)
    Value: list of ACL permissions
    
    Example:
    {
      "admin" = [
        { resource_name = "*", resource_type = "Topic", operation = "All" }
      ]
      "dms_user" = [
        { resource_name = "cdc.*", resource_type = "Topic", operation = "Write" }
      ]
    }
  EOT
  
  type = map(list(object({
    resource_name   = string           # Topic name, Group name, or "Cluster" (* for wildcard)
    resource_type   = string           # "Topic", "Group", or "Cluster"
    operation       = string           # "Read", "Write", "Create", "Delete", "Alter", "Describe", "ClusterAction", "DescribeConfigs", "AlterConfigs", "IdempotentWrite", "All"
    permission_type = optional(string) # "Allow" (default) or "Deny"
    host            = optional(string) # "*" (default) or specific IP/CIDR
  })))
  default = {}
  
  validation {
    condition = alltrue([
      for user, perms in var.user_acls : alltrue([
        for perm in perms : 
          contains(["Topic", "Group", "Cluster"], perm.resource_type)
      ])
    ])
    error_message = "resource_type must be one of: Topic, Group, Cluster"
  }
  
  validation {
    condition = alltrue([
      for user, perms in var.user_acls : alltrue([
        for perm in perms : 
          contains([
            "Read", "Write", "Create", "Delete", "Alter", "Describe", 
            "ClusterAction", "DescribeConfigs", "AlterConfigs", 
            "IdempotentWrite", "All"
          ], perm.operation)
      ])
    ])
    error_message = "operation must be a valid Kafka ACL operation"
  }
}
