resource "random_uuid" "s3_suffix" {
}

resource "aws_s3_bucket" "source_code_bucket_region_1" {
  bucket = "arc-code-${random_uuid.s3_suffix.result}-${var.aws_region_1}"
  acl    = "private"
  force_destroy = true
  
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "S3_code_region_1_public_block" {
  bucket = aws_s3_bucket.source_code_bucket_region_1.id

  block_public_acls   = true
  block_public_policy = true
}

output "source_code_bucket" {
  value = aws_s3_bucket.source_code_bucket_region_1
}
