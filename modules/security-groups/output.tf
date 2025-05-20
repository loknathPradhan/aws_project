output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  description = "EC2 (ASG) Security Group ID"
  value       = aws_security_group.ec2_sg.id
}
