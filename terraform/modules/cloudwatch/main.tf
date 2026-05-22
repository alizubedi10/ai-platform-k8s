resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "mlflow" {
  name              = "/aws/eks/${var.cluster_name}/mlflow"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "model_serving" {
  name              = "/aws/eks/${var.cluster_name}/model-serving"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
                                                                                                                                                                                                                pu                                           am                               },
      {
        type = "metric"
        properties = {
          title  = "EKS Node Memory Utilization"
          per          per          per          per          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]
          ]
        }
      }
                                          erts                            name}-                                          erts    ic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metrresource "aws_cloudwatch_metrresource "aws_  resource "aws_cloudwatch_metrresource "aws_clouderatresource "aws_cloudwatch_m"
  ev  ev  ev  ev  ds  ev2
                                                                                                                                                                                                                                                                                                 io      
                       lu                      = var.tags
}

resource "aws_cloudwatch_metric_alarresource "aws_cloudwatch_metric_alarresource "aws_cloudwatch_metric_alarorresource "aws_cloudwatch_metric_alarresource "aws_cloudwatch_metric_alarresource "aws_cloudw  resource "e_resour_utilizationresource "aws_cloudwatch_metric_alarresource "aws_cloudwatch_metric_alarresource "aws_cloudwatch_metric_alarorresource "aws_cloudwatch_metric_alarresource   resource "aws_cloudwatch_metric_alarr_aresource "aws_cloud_snresource "aws_cloudwatch_mensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}
