resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${terraform.workspace}-app-logs-${random_string.bucket_suffix.result}"
  force_destroy = true  

  tags = {
    Name        = "${terraform.workspace}-app-logs"
    Environment = terraform.workspace
  }
}



# Bucket Policy
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEKSLogsWrite"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.eks_nodes.arn
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.logs_bucket.arn,
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
      }
    ]
  })
}


# Block public access
resource "aws_s3_bucket_public_access_block" "logs_public_access_block" {
  bucket = aws_s3_bucket.logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}




