# Configure the AWS hosts
variable "instances" {
  default = [
    "boundary-1-prod",
    "boundary-2-prod",
  ]
}

variable "vm_tags" {
  default = [
    { "Name" : "boundary-1-prod", "service-type" : "backend", "application" : "users" },
    { "Name" : "boundary-2-prod", "service-type" : "backend", "application" : "orders" },
  ]
}

resource "aws_security_group" "boundary-ssh" {
  name        = "boundary_allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags   = var.tags
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

resource "aws_instance" "boundary_instance" {
  count = length(var.instances)

  ami                    = "ami-083602cee93914c0c"
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.boundary-ssh.id]
  tags                   = var.vm_tags[count.index]
}
