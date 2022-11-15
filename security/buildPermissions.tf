resource "aws_iam_role" "codeBuildServiceRole" {
  name               = "codeBuildServiceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_by_codebuild.json
}

resource "aws_iam_role_policy_attachment" "codeBuild-role-attachment" {
  role       = aws_iam_role.codeBuildServiceRole.name
  policy_arn = aws_iam_policy.dockerImagePolicy.arn
}

# dockerImagePolicy is in permissions.tf

data "aws_iam_policy_document" "assume_by_codebuild" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "dockerImagePolicy" {
  name   = "dockerImagePolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.dockerImagePermissionsDocument.json
}

# Permissions Documents (json)
data "aws_iam_policy_document" "dockerImagePermissionsDocument" {
  statement {
    sid = "AllowUploadToECR"
    actions = [
      # "ecr:CompleteLayerUpload",
      # "ecr:GetAuthorizationToken",
      # "ecr:UploadLayerPart",
      # "ecr:InitiateLayerUpload",
      # "ecr:BatchCheckLayerAvailability",
      # "ecr:PutImage"
      "ecr:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AWSKMSUse"
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowECSDescribeTaskDefinition"
    effect    = "Allow"
    actions   = ["ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid = "AllowLogging"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}
