resource "aws_ssm_parameter" "vpc_id_1" {
  name        = "/vpc/id"
  description = "The VPC ID"
  type        = "String"
  value       = aws_vpc.main.id
}