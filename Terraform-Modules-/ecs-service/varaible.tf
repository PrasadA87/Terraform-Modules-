variable "ecs_service_security_groups" {
  description = "Security group ids"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
}

# variable "private_namespace_id" {
#   description = "namespace created in vpc for ecs service self discovery"
# }

variable "subnet_ids" {
  description = "Subnet ids"
  type = list(string)
}

# variable "alb_target_group_arn" {
#   description = "Target group arn of alb"
# }

variable "service_name" {
  description = "the name of the micro-service"
}

variable healthcheck {
  description = "healthcheck url for the service"
}

variable "environment" {
  description = "the name of your environment"
}

variable "ecs_cluster_id" {
  description = "object id of the ECS cluster"
}

variable "aws_account_id" {
  description = "AWS account id"
}

variable "alb_arn" {
  description = "AWS account id"
}

variable "lb_listener_port" {
  description = "Listener port for LB, has to be unique for every service"
}

variable "container_port" {
  description = "container port to be added in task definition"
  type = number
}