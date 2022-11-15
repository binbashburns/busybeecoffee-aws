data "aws_caller_identity" "current" {}

resource "aws_codecommit_repository" "busybee" {
  repository_name = "busybeeAppSource"
  description     = "This is the Sample App Repository"
}

resource "aws_codebuild_project" "busybeeProdBuild" {
  name         = "busybeeProdBuild"
  description  = "Build a docker image of the app"
  service_role = var.codeBuildServiceRoleArn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "busybeeProject"
      stream_name = "prod/build"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "DEPLOY_EXECUTION_ROLE"
      value = var.codeDeployServiceRoleArn
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.repositoryUrl
    }

    environment_variable {
      name  = "TASK_DEFINITION"
      value = "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.taskFamily}"
    }

    environment_variable {
      name  = "FAMILY"
      value = var.taskFamily
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = local.container_name
    }

    environment_variable {
      name  = "SUBNET_1"
      value = var.appA
    }

    environment_variable {
      name  = "SUBNET_2"
      value = var.appB
    }

    environment_variable {
      name  = "SUBNET_3"
      value = var.appC
    }

    environment_variable {
      name  = "SECURITY_GROUP"
      value = var.EcsSG
    }
  }

  tags = {
    Environment = "Production"
  }

}

locals {
  container_name = "ecs-busybee-home"
}

resource "aws_codedeploy_app" "busybeeApp" {
  compute_platform = "ECS"
  name             = "busybeeApp"
}

resource "aws_codedeploy_deployment_config" "busybeeAppDeploymentConfig" {
  deployment_config_name = "busybeeAppDeploymentConfig"
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "AllAtOnce"
  }
}

resource "aws_codedeploy_deployment_group" "busybeeAppDeploymentGroup" {
  app_name               = aws_codedeploy_app.busybeeApp.name
  deployment_group_name  = "busybeeAppDeploymentGroup"
  deployment_config_name = aws_codedeploy_deployment_config.busybeeAppDeploymentConfig.id
  service_role_arn       = var.codeDeployServiceRoleArn

  ecs_service {
    cluster_name = var.ecsClusterName
    service_name = var.ecsServiceName
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.busybeeListenerArn]
      }

      target_group {
        name = var.busybeeTG1
      }

      target_group {
        name = var.busybeeTG2
      }
    }
  }
}

resource "aws_codepipeline" "busybeeProdPipeline" {
  name     = "busybeeProdPipeline"
  role_arn = var.codePipelineServiceRoleArn

  artifact_store {
    location = var.sourceCodeBucketName
    type     = "S3"
  }

  stage {
    name = "Source"

    # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeCommit.html#action-reference-CodeCommit-config
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["sourceArtifact"]

      configuration = {
        RepositoryName = "busybeeAppSource"
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["sourceArtifact"]
      output_artifacts = ["buildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.busybeeProdBuild.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["buildArtifact"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.busybeeApp.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.busybeeAppDeploymentGroup.deployment_group_name
        TaskDefinitionTemplateArtifact = "buildArtifact"
        AppSpecTemplateArtifact        = "buildArtifact"
      }
    }
  }
}