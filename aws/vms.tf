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


resource "tls_private_key" "ssh_ca_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

locals {
  user_data = {
    write_files = [
      {
        content     = base64encode(tls_private_key.ssh_ca_key.public_key_openssh)
        encoding    = "b64"
        owner       = "root:root"
        path        = "/etc/ssh/trusted-user-ca-keys.pub"
        permissions = "0600"
      }
    ]

    runcmd = concat(
      [
        "echo \"TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pub\" >> /etc/ssh/sshd_config",
        "systemctl restart sshd"
      ]
    )
  }
}

resource "aws_instance" "boundary_instance" {
  count = length(var.instances)

  ami                    = local.image_id
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnets[count.index]
  key_name               = aws_key_pair.bitrock.key_name
  vpc_security_group_ids = [aws_security_group.boundary-ssh.id]
  tags                   = var.vm_tags[count.index]


  user_data_base64 = base64encode(<<EOF
## template: jinja
#cloud-config
${yamlencode(local.user_data)}
EOF
  )
}
