variable "aws_region" {}
variable "vpc_cidr" {}
variable "availability_zones" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "name" {
  description = "Name prefix for all resources"
  type        = string
}
variable "ami_id" {}
variable "instance_type" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "key_name" {}



