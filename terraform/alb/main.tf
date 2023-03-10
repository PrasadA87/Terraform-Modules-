######################################################
##################### application load balancer ######


resource "aws_lb" "alb" {
  name               = "${var.app_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_groups]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Name = "alb-${var.environment}"
  }
}


# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "80"
#   protocol          = "HTTP"
#   # ssl_policy        = "ELBSecurityPolicy-2016-08"
#   # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.listner.arn
#   }
# }

# resource "aws_lb_target_group" "ip-example" {
#   name        = "tf-example-lb-tg"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = aws_vpc.main.id
# }

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }
