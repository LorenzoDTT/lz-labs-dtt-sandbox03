variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "environment_prefix" {
  description = "Environment prefix (e.g., dev, staging, prod)"
  type        = string
}

variable "solution_name" {
  description = "Solution name"
  type        = string
}

variable "azs" {
  type = map(string)
}

variable "name_prefix" {
  type    = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
}