resource "aws_sns_topic" "user_updates" {
  name = "notify-team"
}
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.email_notification

  depends_on = [
    aws_sns_topic.user_updates
  ]
}