output "BastionSG" {
  value       = aws_security_group.BastionSG.id
  description = "The generated security group id"
}

output "AppSG" {
  value       = aws_security_group.AppSG.id
  description = "The generated security group id"
}

output "AlbSG" {
  value       = aws_security_group.AlbSG.id
  description = "The generated security group id"
}

output "EcsSG" {
  value       = aws_security_group.EcsSG.id
  description = "The generated security group id"
}

output "dbSG" {
  value       = aws_security_group.dbSG.id
  description = "The generated security group id"
}

output "EcsInstanceProfileId" {
  value       = aws_iam_instance_profile.ecsInstanceProfile.id
  description = "The generated security group id"
}

output "ecsExecutionRoleArn" {
  value       = aws_iam_role.ecsServiceRole.arn
  description = "The ARN of the task execution role"
}

output "ecsTaskRoleArn" {
  value       = aws_iam_role.ecsTaskRole.arn
  description = "The ARN of the task execution role"
}

output "ecsServiceRole" {
  value       = aws_iam_role.ecsServiceRole.id
  description = "The ARN of the task execution role"
}

output "codeBuildServiceRoleArn" {
  value = aws_iam_role.codeBuildServiceRole.arn
}

output "codePipelineServiceRoleArn" {
  value = aws_iam_role.codePipelineServiceRole.arn
}

output "codeDeployServiceRoleArn" {
  value = aws_iam_role.codeDeployServiceRole.arn
}

output "s3ReplicationRoleArn" {
  value = aws_iam_role.s3ReplicationRole.arn
}

output "kmsArn" {
  value = aws_kms_key.source.arn
}

output "lambdaRoleArn" {
  value = aws_iam_role.iam_role_for_lambda.arn
}