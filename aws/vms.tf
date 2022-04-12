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
        "echo \"CASignatureAlgorithms ^ssh-rsa\"  >> /etc/ssh/sshd_config",
        "echo \"PubkeyAuthentication yes\"  >> /etc/ssh/sshd_config",
        "systemctl restart sshd"
      ]
    )
  }

  otp_user_data = {
    package_update = true
    packages       = ["unzip"]

    write_files = [
      {
        content = base64encode(templatefile("${path.module}/templates/vault-helper-config.hcl.tpl",
          {
            vault_endpoint = "http://${module.alb.lb_dns_name}:8200"
          }
        ))
        encoding    = "b64"
        owner       = "root:root"
        path        = "/etc/vault-helper.d/config.hcl"
        permissions = "0644"
      }
    ]

    runcmd = concat(
      [
        "wget https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip",
        "unzip vault-ssh-helper_0.2.1_linux_amd64.zip -d /usr/local/bin/",
        # disable common-auth
        "sed -i -e 's/^@include common-auth/#@include common-auth/g' /etc/pam.d/sshd",
        # allow Helper to use pam_exec
        "echo \"auth requisite pam_exec.so quiet expose_authtok log=/tmp/vaultssh.log /usr/local/bin/vault-ssh-helper -config=/etc/vault-helper.d/config.hcl -dev\" | tee -a /etc/pam.d/sshd",
        "echo \"auth optional pam_unix.so not_set_pass use_first_pass nodelay\" | tee -a /etc/pam.d/sshd",
        # enable ChallengeResponseAuthentication
        "sed -i -e 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config",
        # allow to use PAM
        "sed -i -e 's/UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config",
        # disable password authentication
        "sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config",
        # restart SSH server
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


resource "aws_instance" "boundary_otp_instance" {

  ami                    = local.image_id
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnets[2]
  key_name               = aws_key_pair.bitrock.key_name
  vpc_security_group_ids = [aws_security_group.boundary-otp-ssh.id]
  tags                   = { "Name" : "boundary-3-prod", "service-type" : "backend", "application" : "otp" }


  user_data_base64 = base64encode(<<EOF
## template: jinja
#cloud-config
${yamlencode(local.otp_user_data)}
EOF
  )
}

resource "aws_security_group" "boundary-otp-ssh" {
  name        = "boundary_allow_otp_ssh"
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


resource "aws_security_group_rule" "otp_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.boundary-otp-ssh.id
  to_port           = 0
  type              = "egress"
}
