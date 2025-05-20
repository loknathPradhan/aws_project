variable "name" {
  description = "Prefix for naming resources (e.g., demo)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t2.micro)"
  type        = string
}

variable "ec2_sg_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to launch EC2 instances into"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of ALB target group ARNs to register EC2 instances with"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
}

variable "min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
}

variable "key_name" {
  description = "Name of the key pair to use for EC2 instances"
  type        = string
}
