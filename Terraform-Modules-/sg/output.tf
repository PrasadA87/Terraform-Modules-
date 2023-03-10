output "alb-sg_id" {
  value = aws_security_group.alb-sg.id
}

output "ecs-sg_id" {
  value = aws_security_group.ecs-sg.id
}

output "bastion-sg_id" {
  value = aws_security_group.bastion-sg.id
}