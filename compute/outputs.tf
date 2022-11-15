output "myLabKeyPair" {
  value       = aws_key_pair.myKeyPair.key_name
  description = "Lab Key Pair"
}