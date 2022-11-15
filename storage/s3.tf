resource "random_string" "prefix" {
  length  = 5
  special = false
}

resource "aws_s3_bucket" "busybee-project-prod-build" {
  bucket        = join("-", [lower(replace(random_string.prefix.result, "[^a-zA-z0-9]", "x")), "busybee-project-prod-build"])
  force_destroy = true

  versioning {
    enabled = true
  }

  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_replication_configuration" "busybee-project-prod-build" {
  bucket = aws_s3_bucket.busybee-project-prod-build.id
  role   = var.s3ReplicationRoleArn

  rule {
    id     = "rule_id"
    status = "Enabled"

    destination {
      bucket = var.destBucketArn
      encryption_configuration {
        replica_kms_key_id = var.destKmsArn
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "busybee-project-prod-build" {
  bucket = aws_s3_bucket.busybee-project-prod-build.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "busybee-project-prod-build" {
  bucket = aws_s3_bucket.busybee-project-prod-build.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "busybee-project-prod-build" {
  bucket = aws_s3_bucket_versioning.busybee-project-prod-build.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kmsArn
      sse_algorithm     = "aws:kms"
    }
  }
}