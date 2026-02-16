module "vpc" {
  source      = "./modules/sandbox_vpc"
  region      = var.aws_region
  vpc_cidr    = var.vpc_cidr
  name_prefix = var.name_prefix
  azs         = var.azs
}