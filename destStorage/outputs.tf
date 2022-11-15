
output "destBucketArn" {
  value       = aws_s3_bucket.busybee-destination-bucket.arn
  description = "The s3 bucket's ARN"
}

output "destKmsArn" {
  value = aws_kms_key.dest.arn
}

output "coffeeMenuBackup" {
  value = aws_s3_bucket.busybee-menu-backup.bucket
}
