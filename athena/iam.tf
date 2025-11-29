# =============================================================================
# IAM Roles - Dynamic Creation (No Explicit Deny - IAM default is deny)
# =============================================================================

resource "aws_iam_role" "this" {
  for_each = var.user_groups

  name        = "${var.app_name}-${replace(each.key, "_", "-")}-${var.env}"
  description = each.value.description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = each.value.mfa_required ? {
          Bool = { "aws:MultiFactorAuthPresent" = "true" }
        } : null
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name       = "${var.app_name}-${replace(each.key, "_", "-")}"
    UserGroup  = each.key
    MNPIAccess = tostring(each.value.mnpi_access)
  })
}

resource "aws_iam_role_policy" "this" {
  for_each = var.user_groups

  name = "${var.app_name}-${replace(each.key, "_", "-")}-policy"
  role = aws_iam_role.this[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # Athena Workgroup Access
      [
        {
          Sid    = "AthenaWorkgroupAccess"
          Effect = "Allow"
          Action = concat(
            [
              "athena:StartQueryExecution",
              "athena:StopQueryExecution",
              "athena:GetQueryExecution",
              "athena:GetQueryResults",
              "athena:GetWorkGroup",
              "athena:BatchGetQueryExecution",
              "athena:ListQueryExecutions"
            ],
            each.value.can_manage_tables ? [
              "athena:CreateNamedQuery",
              "athena:DeleteNamedQuery",
              "athena:GetNamedQuery",
              "athena:ListNamedQueries"
            ] : []
          )
          Resource = aws_athena_workgroup.this[each.key].arn
        }
      ],

      # Glue Catalog Access
      [
        {
          Sid    = "GlueCatalogAccess"
          Effect = "Allow"
          Action = concat(
            [
              "glue:GetDatabase",
              "glue:GetDatabases",
              "glue:GetTable",
              "glue:GetTables",
              "glue:GetPartition",
              "glue:GetPartitions",
              "glue:BatchGetPartition"
            ],
            each.value.can_manage_tables ? [
              "glue:CreateTable",
              "glue:UpdateTable",
              "glue:DeleteTable",
              "glue:CreatePartition",
              "glue:BatchCreatePartition",
              "glue:UpdatePartition",
              "glue:DeletePartition",
              "glue:BatchDeletePartition"
            ] : []
          )
          Resource = concat(
            ["arn:aws:glue:${var.region}:${var.account_id}:catalog"],
            [for db in compact(local.user_group_databases[each.key]) : "arn:aws:glue:${var.region}:${var.account_id}:database/${db}"],
            [for db in compact(local.user_group_databases[each.key]) : "arn:aws:glue:${var.region}:${var.account_id}:table/${db}/*"]
          )
        }
      ],

      # S3 Data Lake Access
      [
        {
          Sid    = "S3DataLakeRead"
          Effect = "Allow"
          Action = concat(
            [
              "s3:GetObject",
              "s3:ListBucket",
              "s3:GetBucketLocation"
            ],
            each.value.can_manage_tables ? [
              "s3:PutObject",
              "s3:DeleteObject"
            ] : []
          )
          Resource = concat(
            [for bucket in compact(local.user_group_buckets[each.key]) : bucket],
            [for bucket in compact(local.user_group_buckets[each.key]) : "${bucket}/*"]
          )
        }
      ],

      # S3 Query Results Access
      [
        {
          Sid    = "S3QueryResultsAccess"
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:AbortMultipartUpload"
          ]
          Resource = "${aws_s3_bucket.athena_results.arn}/${each.key}/*"
        },
        {
          Sid    = "S3QueryResultsList"
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ]
          Resource = aws_s3_bucket.athena_results.arn
        }
      ],

      # KMS Access
      [
        {
          Sid    = "KMSAccess"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:DescribeKey"
          ]
          Resource = local.user_group_kms_keys[each.key]
        }
      ]
    )
  })
}
