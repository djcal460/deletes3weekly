provider "archive" {}
data "archive_file" "zip" {
  type        = "zip"
  source_file = "s3-automation.py"
  output_path = "s3-automation.zip"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
  statement {
    sid = ""
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

#Generally would tailer these policies so they are not full access
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
  role = aws_iam_role.lambda_role.name
}
resource "aws_iam_role_policy_attachment" "events" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  role = aws_iam_role.lambda_role.name
}
resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  role = aws_iam_role.lambda_role.name
}
resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.lambda_role.name
}
resource "aws_iam_role_policy_attachment" "sns" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role = aws_iam_role.lambda_role.name
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json

  depends_on = [
    data.aws_iam_policy_document.lambda_policy
  ]
}

resource "aws_lambda_function" "lambda" {
  function_name = "s3-automation"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.lambda_role.arn
  handler = "s3-automation.lambda_handler"
  runtime = "python3.9"

  depends_on = [
    aws_iam_role.lambda_role,
    aws_iam_role_policy_attachment.cloudwatch,
    aws_iam_role_policy_attachment.events,
    aws_iam_role_policy_attachment.lambda,
    aws_iam_role_policy_attachment.s3
  ]
}