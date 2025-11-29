resource "random_password" "scram_password" {
  for_each = var.scram_users
  
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret" "scram_secret" {
  for_each = var.scram_users
  
  name                    = "AmazonMSK_${var.app_name}_${var.env}_${each.key}"
  description             = "SCRAM credentials for MSK user ${each.key} in ${var.env} environment"
  kms_key_id              = aws_kms_key.msk.arn
  recovery_window_in_days = 7
  
  tags = merge(
    var.common_tags,
    {
      Name        = "AmazonMSK_${var.app_name}_${var.env}_${each.key}"
      Environment = var.env
      User        = each.key
    }
  )
}

resource "aws_secretsmanager_secret_version" "scram_secret_val" {
  for_each = var.scram_users
  
  secret_id = aws_secretsmanager_secret.scram_secret[each.key].id
  secret_string = jsonencode({
    username = each.key
    password = random_password.scram_password[each.key].result
  })
}

resource "aws_secretsmanager_secret_policy" "scram_policy" {
  for_each   = var.scram_users
  secret_arn = aws_secretsmanager_secret.scram_secret[each.key].arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSKafkaResourcePolicy"
        Effect = "Allow"
        Principal = {
          Service = "kafka.amazonaws.com"
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.scram_secret[each.key].arn
      }
    ]
  })
}

resource "aws_msk_scram_secret_association" "this" {
  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = [for secret in aws_secretsmanager_secret.scram_secret : secret.arn]
  
  depends_on = [
    aws_secretsmanager_secret_version.scram_secret_val,
    aws_secretsmanager_secret_policy.scram_policy
  ]
}
