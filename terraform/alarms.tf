# 1. Metric filter: every log line containing "OutOfMemoryError" adds 1 to a metric
resource "aws_cloudwatch_log_metric_filter" "oom" {
  name           = "${var.project_name}-oom-filter"
  log_group_name = aws_cloudwatch_log_group.app.name
  pattern        = "\"OutOfMemoryError\""

  metric_transformation {
    name          = "OOMErrors"
    namespace     = "Selfheal"
    value         = "1"
    default_value = "0"
  }
}

# 2. Alarm: if OOMErrors >= 1 within 1 minute, notify the SNS topic
resource "aws_cloudwatch_metric_alarm" "oom" {
  alarm_name          = "${var.project_name}-oom-alarm"
  alarm_description   = "Java OutOfMemoryError detected in selfheal-app logs"
  namespace           = "Selfheal"
  metric_name         = aws_cloudwatch_log_metric_filter.oom.metric_transformation[0].name
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# 3. EC2 system status check: if AWS hardware/host fails, auto-recover the instance and notify
resource "aws_cloudwatch_metric_alarm" "ec2_system_check" {
  alarm_name          = "${var.project_name}-ec2-system-check"
  alarm_description   = "EC2 system status check failed - auto-recovering instance"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  alarm_actions = [
    "arn:aws:automate:ap-south-1:ec2:recover",
    aws_sns_topic.alerts.arn
  ]
  ok_actions = [aws_sns_topic.alerts.arn]
}