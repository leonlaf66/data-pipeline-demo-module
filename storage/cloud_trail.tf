# --- Audit Log Bucket ---
resource "aws_s3_bucket" "audit" {
  bucket = "${var.app_name}-cloudtrail-logs-${var.account_id}-${var.env}"
  
  tags = merge(
    var.common_tags,
    {
      Name    = "${var.app_name}-cloudtrail-logs"
      Purpose = "CloudTrail Audit Logs"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket = aws_s3_bucket.audit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "audit" {
  bucket = aws_s3_bucket.audit.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.audit.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    id     = "transition-audit-logs"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555
    }
  }
}

# --- CloudTrail ---
resource "aws_cloudtrail" "datalake_audit" {
  name                          = "${var.app_name}-datalake-audit-trail-${var.env}"
  s3_bucket_name                = aws_s3_bucket.audit.id
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_logging                = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${aws_s3_bucket.raw_mnpi.arn}/*",
        "${aws_s3_bucket.raw_public.arn}/*",
        "${aws_s3_bucket.curated_mnpi.arn}/*",
        "${aws_s3_bucket.curated_public.arn}/*",
        "${aws_s3_bucket.analytics_mnpi.arn}/*",
        "${aws_s3_bucket.analytics_public.arn}/*"
      ]
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
  
  tags = merge(
    var.common_tags,
    {
      Purpose    = "DataLake Access Audit"
      Compliance = "MNPI-Tracking"
    }
  )

  depends_on = [aws_s3_bucket_policy.audit]
}
