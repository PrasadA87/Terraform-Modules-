
resource "aws_ecs_cluster" "demo" {
  name = "${var.app_name}-${var.environment}"
}