resource "random_string" "prefix" {
  length  = 5
  special = false
}


resource "aws_s3_bucket" "busybee-destination-bucket" {
  bucket        = join("-", [lower(replace(random_string.prefix.result, "[^a-zA-z0-9]", "x")), "busybee-project-prod-build"])
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_kms_key.dest]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "busybee-destination-bucket" {
  bucket = aws_s3_bucket.busybee-destination-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dest.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "dest" {
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "dest" {
  name          = "alias/${random_string.prefix.result}dest"
  target_key_id = aws_kms_key.dest.key_id
}

resource "aws_s3_bucket" "busybee-menu-backup" {
  bucket        = join("-", [lower(replace(random_string.prefix.result, "[^a-zA-z0-9]", "x")), "busybee-menu-backup"])
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

}