resource "aws_s3_bucket" "report_bucket" {
  bucket = "my-report-bucket-1086"

  tags = {
    Name        = "My bucket for uploading reports"
    Environment = "dev"
  }
}
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.report_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.report_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}