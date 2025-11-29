# =============================================================================
# Athena Workgroups - Dynamic Creation
# =============================================================================

resource "aws_athena_workgroup" "this" {
  for_each = var.user_groups

  name        = "${var.app_name}-${replace(each.key, "_", "-")}-${var.env}"
  description = each.value.description
  state       = "ENABLED"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = var.athena_bytes_scanned_cutoff * each.value.bytes_limit_multiplier

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/${each.key}/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = each.value.mnpi_access ? var.kms_keys.mnpi : var.kms_keys.public
      }
    }

    engine_version {
      selected_engine_version = "Athena engine version 3"
    }
  }

  tags = merge(var.common_tags, {
    Name       = "${var.app_name}-${replace(each.key, "_", "-")}"
    UserGroup  = each.key
    MNPIAccess = tostring(each.value.mnpi_access)
  })
}
