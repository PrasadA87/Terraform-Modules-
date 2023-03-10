
variable "alb_security_groups" {
  description = "Security group ids"
  type = string
}

variable "subnet_ids" {
  description = "Subnet ids"
  type = list(string)
}

# variable "subnet_ids2" {
#   description = "Subnet ids"
#   #type = list(string)
# }

variable "vpc_id" {
  description = "The VPC ID"
}

# variable "name" {
#   description = "the name of your stack, e.g. \"demo\""
# }

variable "app_name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}