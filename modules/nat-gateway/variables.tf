variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be deployed"
  type        = list(string)
}

variable "igw_dependency" {
  description = "Dependency placeholder for IGW creation"
  type        = any
}
