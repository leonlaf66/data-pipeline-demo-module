# KMS Keys Outputs
output "kms_key_mnpi_arn" {
  value       = aws_kms_key.mnpi.arn
  description = "The ARN of the KMS Key used for MNPI data"
}

output "kms_key_public_arn" {
  value       = aws_kms_key.public.arn
  description = "The ARN of the KMS Key used for Public data"
}

output "kms_key_mnpi_id" {
  value       = aws_kms_key.mnpi.key_id
  description = "The ID of the KMS Key used for MNPI data"
}

output "kms_key_public_id" {
  value       = aws_kms_key.public.key_id
  description = "The ID of the KMS Key used for Public data"
}

# S3 Buckets Outputs - Raw Layer
output "bucket_raw_mnpi_arn" {
  value       = aws_s3_bucket.raw_mnpi.arn
  description = "ARN of the Raw MNPI S3 bucket"
}

output "bucket_raw_mnpi_id" {
  value       = aws_s3_bucket.raw_mnpi.id
  description = "Name of the Raw MNPI S3 bucket"
}

output "bucket_raw_public_arn" {
  value       = aws_s3_bucket.raw_public.arn
  description = "ARN of the Raw Public S3 bucket"
}

output "bucket_raw_public_id" {
  value       = aws_s3_bucket.raw_public.id
  description = "Name of the Raw Public S3 bucket"
}

# S3 Buckets Outputs - Curated Layer
output "bucket_curated_mnpi_arn" {
  value       = aws_s3_bucket.curated_mnpi.arn
  description = "ARN of the Curated MNPI S3 bucket"
}

output "bucket_curated_mnpi_id" {
  value       = aws_s3_bucket.curated_mnpi.id
  description = "Name of the Curated MNPI S3 bucket"
}

output "bucket_curated_public_arn" {
  value       = aws_s3_bucket.curated_public.arn
  description = "ARN of the Curated Public S3 bucket"
}

output "bucket_curated_public_id" {
  value       = aws_s3_bucket.curated_public.id
  description = "Name of the Curated Public S3 bucket"
}

# S3 Buckets Outputs - Analytics Layer
output "bucket_analytics_mnpi_arn" {
  value       = aws_s3_bucket.analytics_mnpi.arn
  description = "ARN of the Analytics MNPI S3 bucket"
}

output "bucket_analytics_mnpi_id" {
  value       = aws_s3_bucket.analytics_mnpi.id
  description = "Name of the Analytics MNPI S3 bucket"
}

output "bucket_analytics_public_arn" {
  value       = aws_s3_bucket.analytics_public.arn
  description = "ARN of the Analytics Public S3 bucket"
}

output "bucket_analytics_public_id" {
  value       = aws_s3_bucket.analytics_public.id
  description = "Name of the Analytics Public S3 bucket"
}

# Glue Catalog Databases Outputs - Raw Layer
output "glue_database_raw_mnpi_name" {
  value       = aws_glue_catalog_database.raw_mnpi.name
  description = "Name of the Glue catalog database for Raw MNPI data"
}

output "glue_database_raw_public_name" {
  value       = aws_glue_catalog_database.raw_public.name
  description = "Name of the Glue catalog database for Raw Public data"
}

# Glue Catalog Databases Outputs - Curated Layer
output "glue_database_curated_mnpi_name" {
  value       = aws_glue_catalog_database.curated_mnpi.name
  description = "Name of the Glue catalog database for Curated MNPI data"
}

output "glue_database_curated_public_name" {
  value       = aws_glue_catalog_database.curated_public.name
  description = "Name of the Glue catalog database for Curated Public data"
}

# Glue Catalog Databases Outputs - Analytics Layer
output "glue_database_analytics_mnpi_name" {
  value       = aws_glue_catalog_database.analytics_mnpi.name
  description = "Name of the Glue catalog database for Analytics MNPI data"
}

output "glue_database_analytics_public_name" {
  value       = aws_glue_catalog_database.analytics_public.name
  description = "Name of the Glue catalog database for Analytics Public data"
}

# CloudTrail Outputs
output "cloudtrail_name" {
  value       = aws_cloudtrail.datalake_audit.name
  description = "Name of the CloudTrail trail for audit logging"
}

output "cloudtrail_arn" {
  value       = aws_cloudtrail.datalake_audit.arn
  description = "ARN of the CloudTrail trail for audit logging"
}
