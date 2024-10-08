
#============ VPC =============
# This defines a vpc resource making use of AWS-managed module

module "lcchua-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.stack_name}-${var.env}-tfmod-vpc-${var.rnd_id}"
  cidr = "10.0.0.0/16"

  # azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  azs             = local.availability_zones
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]

  # Note that enable_dns_support and enable_dns_hostnames are defaulted 
  # True in the TF Registry VPC module
  //  enable_nat_gateway = true
  enable_vpn_gateway      = true
  map_public_ip_on_launch = true

  tags = {
    group     = var.stack_name
    form_type = "Terraform Modules"
    Name      = "${var.stack_name}-${var.env}-tfmod-vpc-${var.rnd_id}"
  }
}
output "vpc-id" {
  value = module.lcchua-vpc.default_vpc_id
}

module "lcchua-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "${var.stack_name}-${var.env}-tfmod-sg-${var.rnd_id}"
  description = "Security group for http-https-ssh-db ports"
  vpc_id      = module.lcchua-vpc.vpc_id

  //ingress_cidr_blocks = ["10.10.0.0/16"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL/Aurora"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    group     = var.stack_name
    form_type = "Terraform Modules"
    Name      = "${var.stack_name}-${var.env}-tfmod-sg-${var.rnd_id}"
  }
}
output "sg-id" {
  value = module.lcchua-security-group.security_group_id
}

