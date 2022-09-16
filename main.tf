provider "aws" {
  region = var.region
}

resource "random_pet" "bucket_name" {
  length    = 3
  separator = "-"
}

resource "aws_iam_user" "new_user" {
  name = "cclement"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${random_pet.bucket_name.id}-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  acl = "private"
}

resource "aws_iam_policy" "policy" {
  name        = "${random_pet.bucket_name.id}-policy"
  description = "My test policy"
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}


data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
    effect = "Allow"
  }
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn]
    effect = "Allow"
  }
}