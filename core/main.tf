terraform {
  required_version = ">= 1.3.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

module "vpc" {
  source = "../modules/vpc"
 
  name       = var.name
  vpc_cidr   = var.vpc_cidr
}

module "subnets" {
  source = "../modules/subnet"

  name               = var.name
  vpc_id             = module.vpc.vpc_id
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

module "nat_gateway" {
  source = "../modules/nat-gateway"

  availability_zones = var.availability_zones
  public_subnet_ids  = module.subnets.public_subnet_ids
  igw_dependency      = module.vpc.igw_id
}

module "route_tables" {
  source = "../modules/route-tables"

  vpc_id             = module.vpc.vpc_id
  internet_gateway_id = module.vpc.igw_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  nat_gateway_ids    = module.nat_gateway.nat_gateway_ids
}

module "security_groups" {
  source = "../modules/security-groups"

  name   = var.name
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source          = "../modules/alb"
  name            = var.name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.subnets.public_subnet_ids
  alb_sg_id       = module.security_groups.alb_sg_id
}

module "launch_template_asg" {
  source = "../modules/launch_template_asg"

  name               = var.name
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  ec2_sg_id          = module.security_groups.ec2_sg_id
  private_subnet_ids = module.subnets.private_subnet_ids
  target_group_arns  = [module.alb.target_group_arn]
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  key_name = var.key_name
}



