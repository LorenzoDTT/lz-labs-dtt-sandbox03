######
# IPAM 
######
ipam_common_tags = {
  ResourceType   = "IPAM"
}
ipam = {
  ipam-global = {
    description       = "IPAM Global"
    tier              = "advanced"
    operating_regions = ["us-east-1", "eu-west-1", "eu-south-2"] #changes deleted "af-south-2",  "eu-south-1",
  }
}
ipam_main_pool = {
  eus2 = {
    address_family   = "ipv4"
    nested_ipam_name = "ipam-global"
    region           = "eu-south-2"          # must be one of the operating_regions of the IPAM
    auto_import      = true
    cidr             = ["10.12.0.0/14"]
    tags = {
      AF   = "ipv4"
    }
  }
}
ipam_pool = {
  # shareds
  haynes-shared = {
    address_family            = "ipv4"
    nested_ipam_name          = "ipam-global"
    main_pool_name            = "eus2"
    region                    = "us-east-1" # must be one of the operating_regions of the IPAM, 
    auto_import               = true
    default_netmask_length    = 20      
    min_netmask_length        = 20
    max_netmask_length        = 28
    allow_external_principals = false
    management_account_id     = "#{MANG_ACC_ID}#"
    organizations_id          = "#{ORG_ID}#"
    cidr                      = ["10.12.128.0/18"]
    ram_workloads             = ["ou-5faz-eoevpu48"]
    tags = {   AF = "ipv4" }
  }
  # shareds
  naas-shared = {
    address_family            = "ipv4"
    nested_ipam_name          = "ipam-global"
    main_pool_name            = "eus2"
    region                    = "us-east-1" # must be one of the operating_regions of the IPAM, 
    auto_import               = true
    default_netmask_length    = 20      
    min_netmask_length        = 20
    max_netmask_length        = 28
    allow_external_principals = false
    management_account_id     = "#{MANG_ACC_ID}#"
    organizations_id          = "#{ORG_ID}#"
    cidr                      = ["10.13.128.0/18"]
    ram_workloads             = ["ou-5faz-eoevpu48"]
    tags = {   AF = "ipv4" }
  }
  europe-shared = {
    address_family            = "ipv4"
    nested_ipam_name          = "ipam-global"
    main_pool_name            = "eus2"
    region                    = "eu-west-1" # must be one of the operating_regions of the IPAM, 
    auto_import               = true
    default_netmask_length    = 20      
    min_netmask_length        = 20
    max_netmask_length        = 28
    allow_external_principals = false
    management_account_id     = "#{MANG_ACC_ID}#"
    organizations_id          = "#{ORG_ID}#"
    cidr                      = ["10.14.128.0/18"]
    ram_workloads             = ["ou-5faz-eoevpu48"]
    tags = { AF = "ipv4" }
  }
  corporate-shared = {
    address_family            = "ipv4"
    nested_ipam_name          = "ipam-global"
    main_pool_name            = "eus2"
    region                    = "eu-south-2" # must be one of the operating_regions of the IPAM
    auto_import               = true
    default_netmask_length    = 20      
    min_netmask_length        = 20
    max_netmask_length        = 28
    allow_external_principals = false
    management_account_id     = "#{MANG_ACC_ID}#"
    organizations_id          = "#{ORG_ID}#"
    cidr                      = ["10.15.128.0/18"]
    ram_workloads             = ["ou-5faz-eoevpu48"]
    tags = { AF = "ipv4" }
  }
}

#######
# VPCs
#######
vpc_common_tags = {
  ResourceType   = "VPCs"
}

ipam_pool_managed_with_terraform = true

vpc = {
  egress = {
    ipv4_ipam_pool_name  = "shared-eus2"
    ipv4_netmask_length  = 20
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags                 = {
      netmasklenght = "20"
    }
  }
  dns = {
    ipv4_ipam_pool_name  = "shared-eus2"
    ipv4_netmask_length  = 20
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags                 = {
      netmasklenght = "20"
    }
  }
}

vpc_subnet = {
  egress-public-a = {
    vpc_name        = "egress"
    newbits         = 4            
    netnum          = 0               
    az_zone_number  = 1               
    type            = "public"
    internet_gateway = "igw-egress"
  }

  egrees-private-a = {
    vpc_name        = "egress"
    newbits         = 4
    netnum          = 1               
    az_zone_number  = 1
    type            = "private"
    public_subnet_nat_name = "egress-public-a"
  }

  egrees-cwan = {
    vpc_name        = "egress"
    newbits         = 4
    netnum          = 2
    az_zone_number  = 2
    type            = "private"
    public_subnet_nat_name = "egress-public-a"
  }

  dns-private-a = {
    vpc_name        = "dns"
    newbits         = 4              
    netnum          = 0
    az_zone_number  = 0
    type            = "private"
  }

  dns-private-b = {
    vpc_name        = "dns"
    newbits         = 4              
    netnum          = 1
    az_zone_number  = 0
    type            = "private"
  }

  dns-cwan = {
    vpc_name        = "dns"
    newbits         = 4              
    netnum          = 2
    az_zone_number  = 1
    type            = "private"
  }
}

#########
# route53
#########
route53_common_tags = {
  ResourceType   = "route53"
}

route53 = {
  dns = {
    vpc_name                       = "dns"
    subnet_names                   = ["dns-private-a", "dns-private-b"]
    type                           = ["inbound", "outbound"]
    inbound_resolver_endpoint_type = "IPV4"
    inbound_resolver_protocols     = ["Do53"]
    endpoint_zone_name             = "eu-south-2"                 # zone where the outbound or inbound will be deployed
  }
}

route53_outbound_resolver_rule ={
  resolver-rule1 = {
    domain_name = "."
    rule_type   = "FORWARD"
    route53_name = "dns"
    target_ip    = ["10.20.1.180", "10.20.1.240"]
    allow_external_principals = false
    management_account_id     = "#{MANG_ACC_ID}#"
    organizations_id          = "#{ORG_ID}#"
    principal_ous             = ["ou-5faz-eoevpu48"]
  }
}

route53_inbound_dns = {
  route53-dns = {
    vpc_name    = "dns"
    zone_name   = "eu-south-2" 
  }
}

