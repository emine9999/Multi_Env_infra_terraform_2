output "bucket_name" {
  description = "Name of the logs bucket"
  value       = aws_s3_bucket.logs_bucket.id
}