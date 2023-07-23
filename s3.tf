#terraform.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#provider.tf
provider "aws" {
  region = "us-east-1"
}

 #S3.tf
resource "aws_s3_bucket" "devops_bucket" {
  bucket = "devopsbucketday67"
  versioning {
    enabled = true
  }
}

#s3publiceaccess.tf
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                     = aws_s3_bucket.devops_bucket.id
  block_public_acls          = false
  block_public_policy        = false
  ignore_public_acls         = false
  restrict_public_buckets    = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.devops_bucket.id
  acl    = "public-read"
}

#Iam.tf
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.devops_bucket.id
  policy = data.aws_iam_policy_document.allow_read_only_access.json
}

data "aws_iam_policy_document" "allow_read_only_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::636389623226:user/Mark_furry"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.devops_bucket.arn,
      "${aws_s3_bucket.devops_bucket.arn}/*",
    ]
  }
}
