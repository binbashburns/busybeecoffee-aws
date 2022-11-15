resource "aws_iam_role" "codePipelineServiceRole" {
  name               = "codePipelineServiceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_by_pipeline.json
}

resource "aws_iam_role_policy_attachment" "codePipeline-role-attachment" {
  role       = aws_iam_role.codePipelineServiceRole.name
  policy_arn = aws_iam_policy.pipelinePolicy.arn
}

resource "aws_iam_policy" "pipelinePolicy" {
  name   = "pipelinePolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.pipelinePermissionsDocument.json
}

data "aws_iam_policy_document" "assume_by_pipeline" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "pipelinePermissionsDocument" {
  statement {
    sid       = "AllowPassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.codeDeployServiceRole.arn]
  }

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions   = ["ecr:DescribeImages"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      var.sourceCodeBucketArn,
      "${var.sourceCodeBucketArn}/*",
    ]
  }

  statement {
    actions = [
      "codecommit:ListRepositories",
      "codecommit:GitPull",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = [var.busybeeProdBuildArn]
  }

  statement {
    sid    = "AllowCodeDeploy"
    effect = "Allow"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECS"
    effect = "Allow"

    actions = ["ecs:*"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowResources"
    effect = "Allow"

    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "ecs:*",
      "iam:PassRole"
    ]

    resources = ["*"]
  }
}