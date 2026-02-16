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