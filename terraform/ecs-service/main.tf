# Create ECR repo
resource "aws_ecr_repository" "test" {
  name                 = var.service_name
  image_tag_mutability = "MUTABLE"
  
#   encryption_configuration {
#     encryption_type = "KMS"
#     kms_key = aws_kms_key.mykey.arn
#   }
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "test-ecr" {
  repository = aws_ecr_repository.test.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "keep last 10 images"
     action       = {
       type = "expire"
     }
     selection     = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 10
     }
   }]
  })
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.service_name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.service_name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

### ECS service task and container definition
resource "aws_ecs_task_definition" "tasks" {
  family                   = "${var.service_name}" #"${var.name}-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
   name        =  "${var.service_name}"
   image       = "${var.aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com/${var.service_name}:latest" 
   essential   = true
   environment = [
            {"name": "VARNAME", "value": "VARVAL"}
   ]
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
   }]
   logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = "ap-south-1" #var.region
      }
    } 
  }])
  tags = {
    Name        =  "${var.service_name}"  #"${var.name}-task-${var.environment}"
    Environment = var.environment
  }
  depends_on = [aws_ecr_repository.test]
}


########## Create ECS service  ############
resource "aws_ecs_service" "main" {
 name                               = "${var.service_name}-service"
 cluster                            = var.ecs_cluster_id 
 task_definition                    = aws_ecs_task_definition.tasks.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 
 network_configuration {
   security_groups  = [var.ecs_service_security_groups]  ##ecs-sg
   subnets          = var.subnet_ids
   assign_public_ip = false
 }

#  service_registries {
#    registry_arn = aws_service_discovery_service.ecs.arn
#  }
 
 load_balancer {
   target_group_arn = aws_lb_target_group.main.id         #TODO TODO
   container_name   = var.service_name
   container_port   = var.container_port
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

######### Create target group arn ############
resource "aws_lb_target_group" "main" {
  name        = "${var.service_name}-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
 
   stickiness {
    enabled = false
    type = "lb_cookie"
  }
  
  health_check {
   healthy_threshold   = "2"
   interval            = "60"
   timeout = 30
   protocol            = "HTTP"
   port                = var.container_port
   path                = var.healthcheck
   unhealthy_threshold = "6"
  }
}


######### Create cloudwatch log group for the service
resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.service_name}-ecs-task"
  tags = {
    Name        =  "${var.service_name}"  #"${var.name}-task-${var.environment}"
    Environment = var.environment
  }
}