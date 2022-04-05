locals {
  image_id = data.aws_ami.boundary.id

  private_subnets = coalescelist(var.private_subnets, module.vpc.private_subnets)

  public_subnets = coalescelist(var.public_subnets, module.vpc.public_subnets)

  tags = merge(
    var.tags,
    {
      Owner = "terraform"
    }
  )

  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

data "aws_availability_zones" "available" {}

data "aws_ami" "boundary" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  owners      = ["099720109477"]
}

data "aws_s3_bucket_objects" "cloudinit" {
  bucket = aws_s3_bucket.boundary.id

  depends_on = [module.controllers]
}

resource "random_string" "boundary" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_s3_bucket" "boundary" {
  acl           = "private"
  bucket        = "boundary-${random_string.boundary.result}"
  force_destroy = true
  tags          = local.tags
}
