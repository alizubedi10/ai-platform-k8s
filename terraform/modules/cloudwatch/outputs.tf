output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "log_group_application" {
  value = aws_cloudwatch_log_group.application.name
}

output "log_group_mlflow" {
  value = aws_cloudwatch_log_group.mlflow.name
}

output "log_group_model_serving" {
  value = aws_cloudwatch_log_group.model_serving.name
}
