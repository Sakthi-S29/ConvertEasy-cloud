resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "HighCPUUsage-ConverteasyBackend"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggers if backend EC2 CPU usage goes above 70% for 2 minutes"
  alarm_actions       = [aws_sns_topic.alert_topic.arn]

  dimensions = {
    InstanceId = aws_instance.backend.id
  }

  tags = {
    Project = "ConvertEasy"
  }
}
resource "aws_sns_topic" "alert_topic" {
  name = "converteasy-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = "sakthisharanm@gmail.com"  # 🔔 Replace with your email
}
