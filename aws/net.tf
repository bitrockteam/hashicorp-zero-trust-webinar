
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.7"

  azs                = data.aws_availability_zones.available.names
  cidr               = var.cidr_block
  create_vpc         = var.vpc_id != "" ? false : true
  enable_nat_gateway = true
  name               = "boundary"

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  tags = local.tags
}
