
output "ecsClusterName" {
  value = aws_ecs_cluster.busybee-Cluster.name
}

output "ecsClusterArn" {
  value = aws_ecs_cluster.busybee-Cluster.arn
}

output "ecsServiceName" {
  value = aws_ecs_service.busybee-Home-Service.name
}

output "ecsServiceArn" {
  value = aws_ecs_service.busybee-Home-Service.cluster
}

output "repositoryUrl" {
  value = aws_ecr_repository.ecs-busybee-home.repository_url
}

output "repositoryArn" {
  value = aws_ecr_repository.ecs-busybee-home.arn
}

output "repositoryName" {
  value = aws_ecr_repository.ecs-busybee-home.name
}

output "taskFamily" {
  value = aws_ecs_task_definition.busybee-App-Task.family
}
