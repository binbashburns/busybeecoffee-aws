data "aws_iam_policy_document" "assume_by_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name               = "iam_role_for_lambda"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_by_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambdaRoleAttachment" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.lambdaPolicy.arn
}

resource "aws_iam_policy" "lambdaPolicy" {
  name   = "lambdaPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambdaPolicyDocument.json
}

data "aws_iam_policy_document" "lambdaPolicyDocument" {
  statement {
    sid = "InvokeLambda"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "HandleStreamData"
    effect = "Allow"

    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "cloudwatch:PutMetricData"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReplicationPermissions"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = ["${var.destCodeBucketArn}/*"]
  }

  statement {
    sid = "PushToFirehose"
    actions = [
      "firehose:DescribeDeliveryStream",
      "firehose:ListDeliveryStreams",
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
      "firehose:UpdateDestination"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"

      values = [
        "s3.${var.source_region}.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"

      values = [
        var.sourceCodeBucketArn
      ]
    }

    resources = [aws_kms_key.source.arn]
  }

  statement {
    sid    = "AllowEncrypt"
    effect = "Allow"
    actions = [
      "kms:Encrypt"
    ]

    resources = [var.destKmsArn]
  }

  statement {
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}
