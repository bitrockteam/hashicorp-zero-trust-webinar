data "aws_ami" "centos7" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = [var.ami_filter_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "product-code"
    values = ["cvugziknvmxgqna9noibqnnsy"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "ssh-key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "bitrock" {
  key_name   = "bitrock_hashicorp_shared_sshkey"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "vault_cluster" {
  count = var.control_plane_instance_count

  ami               = data.aws_ami.centos7.id
  instance_type     = var.control_plane_machine_type
  subnet_id         = local.public_subnets[count.index]
  availability_zone = module.vpc.azs[count.index]
  key_name          = aws_key_pair.bitrock.key_name

  user_data_base64 = module.cloud_init_control_plane.control_plane_user_data

  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_root_size
    volume_type           = var.volume_type
    tags = {
      Name    = format("vault-%.2d", count.index + 1)
      Project = "hashicorp-zero-trust-webinar"
    }
  }

  vpc_security_group_ids = [
    aws_security_group.allow_cluster_basics.id,
    aws_security_group.internal_vault.id
  ]

  associate_public_ip_address = true #tfsec:ignore:AWS012
  iam_instance_profile        = aws_iam_instance_profile.control_plane.id

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = format("vault-%.2d", count.index + 1)
    Project = "hashicorp-zero-trust-webinar"
  }

  lifecycle {
    ignore_changes = [ebs_optimized]
  }
}

resource "aws_volume_attachment" "vault_cluster_ec2" {
  count = var.control_plane_instance_count

  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.vault_cluster_data[count.index].id
  instance_id = aws_instance.vault_cluster[count.index].id
}

resource "aws_ebs_volume" "vault_cluster_data" {
  count = var.control_plane_instance_count

  availability_zone = aws_instance.vault_cluster[count.index].availability_zone
  size              = var.volume_data_size
  type              = var.volume_type
  encrypted         = true

  tags = {
    Name = format("vault-data-%.2d", count.index + 1)
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "vault_kms_unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = [aws_kms_key.vault.arn]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

data "aws_iam_policy_document" "vault_client" {
  statement {
    sid    = "VaultClient"
    effect = "Allow"

    actions = ["ec2:DescribeInstances"]

    resources = ["*"]
  }
}


// aws_iam_role
resource "aws_iam_role" "control_plane" {
  name               = "control-plane-vault"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

// aws_iam_instance_profile
resource "aws_iam_instance_profile" "control_plane" {
  name = "control-plane-vault"
  role = aws_iam_role.control_plane.name
}

// aws_iam_role_policy
resource "aws_iam_role_policy" "vault_kms_unseal" {
  name   = "vault-kms-unseal"
  role   = aws_iam_role.control_plane.id
  policy = data.aws_iam_policy_document.vault_kms_unseal.json
}
# tfsec:ignore:AWS099
resource "aws_iam_role_policy" "vault_aws_auth" {
  name = "control-plane-policy"
  role = aws_iam_role.control_plane.name

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances",
          "iam:GetInstanceProfile",
          "iam:GetUser",
          "iam:GetRole"
        ],
        "Resource": "*"
      },
      {
        "Sid": "ManageOwnAccessKeys",
        "Effect": "Allow",
        "Action": [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:GetAccessKeyLastUsed",
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ],
        "Resource": "arn:aws:iam::*:user/$${aws:username}"
      }
    ]
  }
  EOF
}

module "cloud_init_control_plane" {
  source         = "git::https://github.com/bitrockteam/caravan-cloudinit?ref=refs/tags/v0.1.13"
  cluster_nodes  = { for n in aws_instance.vault_cluster : n.tags["Name"] => n.private_ip }
  vault_endpoint = "http://127.0.0.1:8200"

  dc_name        = "aws-dc"
  auto_auth_type = "aws"
  aws_node_role  = aws_iam_instance_profile.control_plane.name

  partition_prefix        = "p"
  vault_persistent_device = "/dev/sdd"
}


module "vault_cluster" {
  source                         = "git::https://github.com/bitrockteam/caravan-vault//modules/cluster-raft?ref=v0.3.17"
  control_plane_nodes_ids        = [for n in aws_instance.vault_cluster : n.arn]
  control_plane_nodes            = { for n in aws_instance.vault_cluster : n.tags["Name"] => n.private_ip }
  control_plane_nodes_public_ips = { for n in aws_instance.vault_cluster : n.tags["Name"] => n.public_ip }
  ssh_private_key                = chomp(tls_private_key.ssh_key.private_key_pem)
  ssh_user                       = "centos"
  ssh_timeout                    = "240s"
  prefix                         = "hashicorp-webinar"

  unseal_type = "aws"

  aws_kms_region = var.region
  aws_kms_key_id = aws_kms_key.vault.id
  aws_access_key = null
  aws_secret_key = null
  aws_endpoint   = null

  depends_on = [
    aws_volume_attachment.vault_cluster_ec2
  ]
}


resource "aws_security_group" "allow_cluster_basics" {
  name        = "hashicorp_cluster_ssh_in"
  description = "Allow Hashicorp Cluster Traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    description = "ping"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh internal"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = {
    Name      = "hashicorp_cluster_ssh_in"
    Project   = "hashicorp-zero-trust-webinar"
    Component = "vault"
  }
}

resource "aws_security_group" "internal_vault" {
  name        = "hashicorp_internal_vault_in"
  description = "Allow Hashicorp Vault Internal Traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name      = "hashicorp_cluster_in"
    Project   = "hashicorp-zero-trust-webinar"
    Component = "vault"
  }

}
