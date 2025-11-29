# MNPI Raw Bucket
resource "aws_s3_bucket" "raw_mnpi" {
  bucket = "${var.app_name}-raw-mnpi-${var.account_id}-${var.env}"
  tags   = merge(var.common_tags, { Tier = "Raw", Sensitivity = "MNPI" })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_mnpi" {
  bucket = aws_s3_bucket.raw_mnpi.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mnpi.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "raw_mnpi" {
  bucket = aws_s3_bucket.raw_mnpi.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "raw_mnpi" {
  bucket = aws_s3_bucket.raw_mnpi.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "raw_mnpi" {
  bucket = aws_s3_bucket.raw_mnpi.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

# Public Raw Bucket
resource "aws_s3_bucket" "raw_public" {
  bucket = "${var.app_name}-raw-public-${var.account_id}-${var.env}"
  tags   = merge(var.common_tags, { Tier = "Raw", Sensitivity = "Public" })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_public" {
  bucket = aws_s3_bucket.raw_public.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.public.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "raw_public" {
  bucket = aws_s3_bucket.raw_public.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "raw_public" {
  bucket = aws_s3_bucket.raw_public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "raw_public" {
  bucket = aws_s3_bucket.raw_public.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

# --- MNPI Curated ---
resource "aws_s3_bucket" "curated_mnpi" {
  bucket = "${var.app_name}-curated-mnpi-${var.account_id}-${var.env}"
  tags   = merge(var.common_tags, { Tier = "Curated", Sensitivity = "MNPI" })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated_mnpi" {
  bucket = aws_s3_bucket.curated_mnpi.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mnpi.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "curated_mnpi" {
  bucket = aws_s3_bucket.curated_mnpi.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "curated_mnpi" {
  bucket = aws_s3_bucket.curated_mnpi.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "curated_mnpi" {
  bucket = aws_s3_bucket.curated_mnpi.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# --- Public Curated ---
resource "aws_s3_bucket" "curated_public" {
  bucket = "${var.app_name}-curated-public-${var.account_id}-${var.env}"
  tags   = merge(var.common_tags, { Tier = "Curated", Sensitivity = "Public" })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated_public" {
  bucket = aws_s3_bucket.curated_public.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.public.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "curated_public" {
  bucket = aws_s3_bucket.curated_public.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "curated_public" {
  bucket = aws_s3_bucket.curated_public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "curated_public" {
  bucket = aws_s3_bucket.curated_public.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# --- MNPI Analytics ---
resource "aws_s3_bucket" "analytics_mnpi" {
  bucket = "${var.app_name}-analytics-mnpi-${var.account_id}-${var.env}"
  tags   = merge(var.common_tags, { Tier = "Analytics", Sensitivity = "MNPI" })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analytics_mnpi" {
  bucket = aws_s3_bucket.analytics_mnpi.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mnpi.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "analytics_mnpi" {
  bucket = aws_s3_bucket.analytics_mnpi.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "analytics_mnpi" {
  bucket = aws_s3_bucket.analytics_mnpi.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Public Analytics ---
resource "aws_s3_bucket" "analytics_public" {
  bucket = "${var.app_name}-analytics-public-${var.account_id}-${var.env}"
  tags   = merge(var.common_tags, { Tier = "Analytics", Sensitivity = "Public" })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analytics_public" {
  bucket = aws_s3_bucket.analytics_public.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.public.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "analytics_public" {
  bucket = aws_s3_bucket.analytics_public.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "analytics_public" {
  bucket = aws_s3_bucket.analytics_public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Bucket Policies - Security Controls

data "aws_iam_policy_document" "secure_bucket_policy" {
  statement {
    sid     = "EnforceSSL"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.raw_mnpi.arn, "${aws_s3_bucket.raw_mnpi.arn}/*",
      aws_s3_bucket.raw_public.arn, "${aws_s3_bucket.raw_public.arn}/*",
      aws_s3_bucket.curated_mnpi.arn, "${aws_s3_bucket.curated_mnpi.arn}/*",
      aws_s3_bucket.curated_public.arn, "${aws_s3_bucket.curated_public.arn}/*",
      aws_s3_bucket.analytics_mnpi.arn, "${aws_s3_bucket.analytics_mnpi.arn}/*",
      aws_s3_bucket.analytics_public.arn, "${aws_s3_bucket.analytics_public.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid     = "DenyIncorrectEncryptionHeader"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.raw_mnpi.arn}/*",
      "${aws_s3_bucket.raw_public.arn}/*",
      "${aws_s3_bucket.curated_mnpi.arn}/*",
      "${aws_s3_bucket.curated_public.arn}/*",
      "${aws_s3_bucket.analytics_mnpi.arn}/*",
      "${aws_s3_bucket.analytics_public.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

resource "aws_s3_bucket_policy" "raw_mnpi" {
  bucket = aws_s3_bucket.raw_mnpi.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}

resource "aws_s3_bucket_policy" "raw_public" {
  bucket = aws_s3_bucket.raw_public.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}

resource "aws_s3_bucket_policy" "curated_mnpi" {
  bucket = aws_s3_bucket.curated_mnpi.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}

resource "aws_s3_bucket_policy" "curated_public" {
  bucket = aws_s3_bucket.curated_public.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}

resource "aws_s3_bucket_policy" "analytics_mnpi" {
  bucket = aws_s3_bucket.analytics_mnpi.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}

resource "aws_s3_bucket_policy" "analytics_public" {
  bucket = aws_s3_bucket.analytics_public.id
  policy = data.aws_iam_policy_document.secure_bucket_policy.json
}
