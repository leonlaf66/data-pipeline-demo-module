output "bootstrap_brokers_sasl_scram" {
  description = "Standard AWS MSK Endpoint (SCRAM)"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
}

output "bootstrap_brokers_sasl_iam" {
  description = "Standard AWS MSK Endpoint (IAM) - Optional"
  value       = var.enable_iam ? aws_msk_cluster.this.bootstrap_brokers_sasl_iam : null
}

output "bootstrap_brokers_nlb" {
  description = "Stable NLB Endpoint (kafka-bootstrap.internal:9096)"
  value       = var.private_hosted_zone_id != "" ? "kafka-bootstrap.${var.app_name}.internal:9096" : "${aws_lb.msk_nlb.dns_name}:9096"
}

output "security_group_id" {
  value = aws_security_group.msk.id
}

output "kms_key_arn" {
  value = aws_kms_key.msk.arn
}

output "cluster_arn" {
  value = aws_msk_cluster.this.arn
}

output "scram_secret_names" {
  description = "Map of SCRAM user names to their Secrets Manager secret names"
  value = {
    for user in var.scram_users : user => "AmazonMSK_${user}"
  }
  # 输出:
  # {
  #   "admin"          = "AmazonMSK_admin"
  #   "debezium"       = "AmazonMSK_debezium"
  #   "s3_sink_mnpi"   = "AmazonMSK_s3_sink_mnpi"
  #   "s3_sink_public" = "AmazonMSK_s3_sink_public"
  # }
}