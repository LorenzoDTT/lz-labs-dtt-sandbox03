/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/1-simple_architecture/terraform/terraform/main.tf ---

# ---------- AWS CLOUD WAN RESOURCES ----------
# Global Network
resource "aws_networkmanager_global_network" "global_network" {
  provider = aws.awsnvirginia

  description = "Global Network - ${var.identifier}"

  tags = {
    Name = "Global Network - ${var.identifier}"
  }
}

# Core Network
resource "aws_networkmanager_core_network" "core_network" {
  provider = aws.awsnvirginia

  description       = "Core Network - ${var.identifier}"
  global_network_id = aws_networkmanager_global_network.global_network.id

  create_base_policy   = true
  base_policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

  tags = {
    Name = "Core Network - ${var.identifier}"
  }
}

# ---------- RESOURCES IN SPAIN ----------
# Spoke VPCs - definition in variables.tf
module "spain_spoke_vpcs" {
  for_each  = var.spain_spoke_vpcs
  source    = "aws-ia/vpc/aws"
  version   = "= 4.5.0"
  providers = { aws = aws.awsspain }

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    endpoints = { netmask = each.value.endpoint_subnet_netmask }
    workload  = { netmask = each.value.workload_subnet_netmask }
    core_network = {
      netmask            = each.value.cnetwork_subnet_netmask
      require_acceptance = false

      tags = each.value.segment == "sharedservice" ? {
        "${each.value.segment}" = "true"
        #segment = each.value.segment
        } : {
        domain = each.value.segment
      }
    }
  }
}

# EC2 Instances (in Spoke VPCs) and EC2 Instance Connect endpoint
# module "spain_compute" {
#   for_each  = module.spain_spoke_vpcs
#   source    = "../../tf_modules/compute"
#   providers = { aws = aws.awsspain }

#   identifier      = var.identifier
#   vpc_name        = each.key
#   vpc             = each.value
#   vpc_information = var.spain_spoke_vpcs[each.key]
# }

# ---------- RESOURCES IN N. VIRGINIA ----------
# Spoke VPCs - definition in variables.tf
module "nvirginia_spoke_vpcs" {
  for_each  = var.nvirginia_spoke_vpcs
  source    = "aws-ia/vpc/aws"
  version   = "= 4.5.0"
  providers = { aws = aws.awsnvirginia }

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    endpoints = { netmask = each.value.endpoint_subnet_netmask }
    workload  = { netmask = each.value.workload_subnet_netmask }
    core_network = {
      netmask            = each.value.cnetwork_subnet_netmask
      require_acceptance = false

      tags = each.value.segment == "sharedservice" ? {
        #each.value.segment = true
        "${each.value.segment}" = "true"
        } : {
        domain = each.value.segment
      }
    }
  }
}

# EC2 Instances (in Spoke VPCs) and EC2 Instance Connect endpoint
# module "nvirginia_compute" {
#   for_each  = module.nvirginia_spoke_vpcs
#   source    = "../../tf_modules/compute"
#   providers = { aws = aws.awsnvirginia }

#   identifier      = var.identifier
#   vpc_name        = each.key
#   vpc             = each.value
#   vpc_information = var.nvirginia_spoke_vpcs[each.key]
# }
