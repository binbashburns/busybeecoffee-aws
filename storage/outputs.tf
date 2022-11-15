output "sourceCodeBucketName" {
  value       = aws_s3_bucket.busybee-project-prod-build.bucket
  description = "The s3 bucket"
}

output "sourceCodeBucketArn" {
  value       = aws_s3_bucket.busybee-project-prod-build.arn
  description = "The s3 bucket's ARN"
}
