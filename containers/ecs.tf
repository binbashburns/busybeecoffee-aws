locals {
  container_name = "ecs-busybee-home"
}

data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}

locals {
  target_groups = [
    "green",
    "blue",
  ]
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                 = "ecs-launch-configuration"
  image_id             = data.aws_ami.ecs_ami.id
  instance_type        = "t3.micro"
  iam_instance_profile = var.ecsInstanceProfileId

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  associate_public_ip_address = "false"
  key_name                    = var.myLabKeyPair

  user_data = <<-EOF
        #!/bin/bash
        echo ECS_CLUSTER=busybee-Cluster >> /etc/ecs/ecs.config;
        echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
        EOF

  security_groups = [var.EcsSG]
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name             = "ecs-autoscaling-group"
  max_size         = "3"
  min_size         = "1"
  desired_capacity = "1"

  vpc_zone_identifier  = [var.appA, var.appB, var.appC]
  launch_configuration = aws_launch_configuration.ecs-launch-configuration.name
  target_group_arns    = [var.busybeeTG1Arn, var.busybeeTG2Arn]
  health_check_type    = "ELB"


  tag {
    key                 = "Name"
    value               = "busybee-ECS"
    propagate_at_launch = true
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "busybee-Cluster" {
  name = "busybee-Cluster"
}


resource "aws_ecs_task_definition" "busybee-App-Task" {
  family                   = "busybee-App-Task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecsExecutionRoleArn
  task_role_arn            = var.ecsTaskRoleArn
  memory                   = 256
  cpu                      = 128
  container_definitions    = file("${path.module}/ecs-images.json")
}


resource "aws_ecs_service" "busybee-Home-Service" {
  name            = "busybee-Home-Service"
  launch_type     = "EC2"
  cluster         = aws_ecs_cluster.busybee-Cluster.arn
  task_definition = "${aws_ecs_task_definition.busybee-App-Task.family}:${aws_ecs_task_definition.busybee-App-Task.revision}"
  desired_count   = 1
  # iam_role                      = var.ecsServiceRole
  deployment_minimum_healthy_percent = "100"
  deployment_maximum_percent         = "200"
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = var.busybeeTG1Arn
    # target_group_arn            = var.busybeeAlbArn
    container_name = local.container_name
    container_port = "80"
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [null_resource.alb_exists]
}


resource "null_resource" "alb_exists" {
  triggers = {
    alb_name = var.busybeeAlbArn
  }
}