# SNS topic: a "channel" that alarms publish to
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

# Email subscription: anything published to the topic gets emailed to you
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}