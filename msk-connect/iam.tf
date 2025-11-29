resource "aws_iam_role" "msk_connect" {
  name = "${var.connector_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "kafkaconnect.amazonaws.com"
      }
    }]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "msk_connect" {
  name = "${var.connector_name}-policy"
  role = aws_iam_role.msk_connect.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "MSKClusterConnect"
          Effect = "Allow"
          Action = [
            "kafka-cluster:Connect",
            "kafka-cluster:DescribeCluster"
          ]
          Resource = var.msk_cluster_arn
        }
      ],
      
      var.connector_type == "source" && length(var.kafka_topics_write) > 0 ? [
        {
          Sid    = "MSKWriteTopics"
          Effect = "Allow"
          Action = [
            "kafka-cluster:CreateTopic",
            "kafka-cluster:DescribeTopic",
            "kafka-cluster:WriteData"
          ]
          Resource = [
            for topic in var.kafka_topics_write :
            "arn:aws:kafka:${var.region}:${var.account_id}:topic/${split("/", var.msk_cluster_arn)[1]}/*/${topic}"
          ]
        }
      ] : [],
      
      var.connector_type == "sink" && length(var.kafka_topics_read) > 0 ? [
        {
          Sid    = "MSKReadTopics"
          Effect = "Allow"
          Action = [
            "kafka-cluster:DescribeTopic",
            "kafka-cluster:ReadData"
          ]
          Resource = [
            for topic in var.kafka_topics_read :
            "arn:aws:kafka:${var.region}:${var.account_id}:topic/${split("/", var.msk_cluster_arn)[1]}/*/${topic}"
          ]
        },
        {
          Sid    = "MSKConsumerGroup"
          Effect = "Allow"
          Action = [
            "kafka-cluster:AlterGroup",
            "kafka-cluster:DescribeGroup"
          ]
          Resource = "arn:aws:kafka:${var.region}:${var.account_id}:group/${split("/", var.msk_cluster_arn)[1]}/*/${var.connector_name}-*"
        }
      ] : [],

      [
        {
          Sid    = "S3PluginAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            var.custom_plugin_bucket_arn,
            "${var.custom_plugin_bucket_arn}/*"
          ]
        }
      ],
      
      var.connector_type == "sink" && var.s3_sink_bucket_arn != null ? [
        {
          Sid    = "S3SinkWrite"
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:AbortMultipartUpload"
          ]
          Resource = "${var.s3_sink_bucket_arn}/*"
        },
        {
          Sid    = "S3SinkList"
          Effect = "Allow"
          Action = "s3:ListBucket"
          Resource = var.s3_sink_bucket_arn
        }
      ] : [],

      length(compact([var.msk_kms_key_arn, var.s3_kms_key_arn, var.secrets_kms_key_arn])) > 0 ? [
        {
          Sid    = "KMSAccess"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ]
          Resource = compact([
            var.msk_kms_key_arn,
            var.s3_kms_key_arn,
            var.secrets_kms_key_arn
          ])
        }
      ] : [],

      [
        {
          Sid    = "VPCNetworkInterface"
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups"
          ]
          Resource = "*"
        }
      ],

      [
        {
          Sid    = "CloudWatchLogs"
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/msk-connect/${var.connector_name}:*"
        },
        {
          Sid    = "CloudWatchLogsCreateGroup"
          Effect = "Allow"
          Action = "logs:CreateLogGroup"
          Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/msk-connect/${var.connector_name}"
        }
      ],

      var.connector_type == "source" && var.rds_secret_arn != null ? [
        {
          Sid    = "SecretsManagerRDS"
          Effect = "Allow"
          Action = "secretsmanager:GetSecretValue"
          Resource = var.rds_secret_arn
        }
      ] : []
    )
  })
}
