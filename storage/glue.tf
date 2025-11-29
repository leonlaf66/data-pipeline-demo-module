# --- Raw Layer Databases ---
resource "aws_glue_catalog_database" "raw_mnpi" {
  name        = "${replace(var.app_name, "-", "_")}_raw_mnpi_${var.env}"
  description = "Raw MNPI Data (CDC/Kafka) - Restricted Access"
  
  location_uri = "s3://${aws_s3_bucket.raw_mnpi.bucket}/"
}

resource "aws_glue_catalog_database" "raw_public" {
  name        = "${replace(var.app_name, "-", "_")}_raw_public_${var.env}"
  description = "Raw Public Data (CDC/Kafka) - General Access"
  
  location_uri = "s3://${aws_s3_bucket.raw_public.bucket}/"
}

# --- Curated Layer Databases ---
resource "aws_glue_catalog_database" "curated_mnpi" {
  name        = "${replace(var.app_name, "-", "_")}_curated_mnpi_${var.env}"
  description = "Curated MNPI Data - Cleaned and Validated"
  
  location_uri = "s3://${aws_s3_bucket.curated_mnpi.bucket}/"
}

resource "aws_glue_catalog_database" "curated_public" {
  name        = "${replace(var.app_name, "-", "_")}_curated_public_${var.env}"
  description = "Curated Public Data - Cleaned and Validated"
  
  location_uri = "s3://${aws_s3_bucket.curated_public.bucket}/"
}

# --- Analytics Layer Databases ---
resource "aws_glue_catalog_database" "analytics_mnpi" {
  name        = "${replace(var.app_name, "-", "_")}_analytics_mnpi_${var.env}"
  description = "Analytics MNPI Data - Ready for Query - Finance Analysts Access"
  
  location_uri = "s3://${aws_s3_bucket.analytics_mnpi.bucket}/"
}

resource "aws_glue_catalog_database" "analytics_public" {
  name        = "${replace(var.app_name, "-", "_")}_analytics_public_${var.env}"
  description = "Analytics Public Data - Ready for Query - All Analysts Access"
  
  location_uri = "s3://${aws_s3_bucket.analytics_public.bucket}/"
}
