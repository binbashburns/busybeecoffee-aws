data "aws_iam_policy_document" "assume_for_replication" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3ReplicationRole" {
  name               = "s3ReplicationRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_for_replication.json
}

resource "aws_iam_role_policy_attachment" "s3ReplicationRole-attachment" {
  role       = aws_iam_role.s3ReplicationRole.name
  policy_arn = aws_iam_policy.s3ReplicationPermissionsPolicy.arn
}

resource "aws_iam_policy" "s3ReplicationPermissionsPolicy" {
  name   = "s3ReplicationPermissionsPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.s3ReplicationPermissionsDocument.json
}

data "aws_iam_policy_document" "s3ReplicationPermissionsDocument" {
  statement {
    sid = "ListingPermissions"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:GetBucketReplication"
    ]
    resources = [var.sourceCodeBucketArn]
  }

  statement {
    sid    = "ObjectPermissions"
    effect = "Allow"

    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionForReplication*",
      "s3:GetObjectVersionAcl"
    ]

    resources = ["${var.sourceCodeBucketArn}/*"]
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
    sid = "AllowLogging"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
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

resource "aws_kms_key" "source" {
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "source" {
  name          = "alias/source"
  target_key_id = aws_kms_key.source.key_id
}