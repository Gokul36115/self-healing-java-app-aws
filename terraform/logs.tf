# Log group: the "folder" in CloudWatch where container logs go
resource "aws_cloudwatch_log_group" "app" {
  name              = "/selfheal/app"
  retention_in_days = 3
}