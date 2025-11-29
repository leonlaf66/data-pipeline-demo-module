# Topic Outputs
output "topic_names" {
  description = "List of created Kafka topic names"
  value       = [for t in kafka_topic.this : t.name]
}

output "topic_details" {
  description = "Map of topic names to their configuration details"
  value = {
    for name, t in kafka_topic.this : name => {
      id                 = t.id
      partitions         = t.partitions
      replication_factor = t.replication_factor
      config             = t.config
    }
  }
}

output "topic_count" {
  description = "Total number of topics created"
  value       = length(kafka_topic.this)
}

# ACL Outputs
output "acl_count" {
  description = "Total number of ACLs created"
  value       = length(kafka_acl.this)
}

output "users_with_acls" {
  description = "List of users with ACL permissions configured"
  value       = keys(var.user_acls)
}

output "acl_summary" {
  description = "Summary of ACLs by user"
  value = {
    for user in keys(var.user_acls) : user => {
      acl_count   = length(var.user_acls[user])
      permissions = [for perm in var.user_acls[user] : "${perm.operation} on ${perm.resource_type}:${perm.resource_name}"]
    }
  }
}

# Configuration Outputs
output "bootstrap_servers" {
  description = "Kafka bootstrap servers used for connection"
  value       = var.bootstrap_servers
}

output "kafka_version_info" {
  description = "Kafka provider version information"
  value = {
    provider_version = "0.5.4"
    admin_user       = var.kafka_admin_username
  }
  sensitive = false
}
