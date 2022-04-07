
locals {
  worker_configuration = templatefile(
    "${path.module}/templates/worker.hcl.tpl",
    {
      controllers   = jsonencode(data.aws_instances.controllers.private_ips)
      tls_disabled  = var.tls_disabled
      tls_cert_path = var.tls_cert_path
      tls_key_path  = var.tls_key_path
      keys = [
        {
          key_id  = aws_kms_key.auth.id
          purpose = "worker-auth"
        }
      ]
    }
  )
}

# Allows the workers to gossip with the controller on :9201
resource "aws_security_group_rule" "controller" {
  from_port                = 9201
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.worker.id
  to_port                  = 9201
  type                     = "ingress"
}

resource "aws_security_group" "worker" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 9202
    protocol    = "TCP"
    to_port     = 9202
  }

  ingress {
    from_port       = 22
    protocol        = "TCP"
    security_groups = [aws_security_group.bastion.id]
    to_port         = 22
  }

  name   = "BoundaryWorker"
  tags   = var.tags
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

module "workers" {
  source = "git::https://github.com/jasonwalsh/terraform-aws-boundary//modules/boundary?ref=refs/tags/v1.1.5"

  auto_scaling_group_name = "BoundaryWorker"
  boundary_release        = var.boundary_release
  bucket_name             = aws_s3_bucket.boundary.id
  desired_capacity        = var.worker_desired_capacity
  iam_instance_profile    = aws_iam_instance_profile.worker.arn
  image_id                = local.image_id
  instance_type           = var.worker_instance_type
  key_name                = aws_key_pair.bitrock.key_name
  max_size                = var.worker_max_size
  min_size                = var.worker_min_size
  security_groups         = [aws_security_group.worker.id]
  tags                    = var.tags
  vpc_zone_identifier     = local.public_subnets

  write_files = [
    {
      content     = local.worker_configuration
      owner       = "root:root"
      path        = "/etc/boundary/configuration.hcl"
      permissions = "0644"
    }
  ]
}

# https://www.boundaryproject.io/docs/configuration/kms/awskms#authentication
#
# Allows the workers to invoke the Decrypt, DescribeKey, and Encrypt
# routines for the worker-auth key.
data "aws_iam_policy_document" "kms" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt"
    ]

    effect = "Allow"

    resources = [aws_kms_key.auth.arn]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "kms" {
  name   = "BoundaryWorkerServiceRolePolicy"
  policy = data.aws_iam_policy_document.kms.json
}

resource "aws_iam_role" "worker" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "ServiceRoleForBoundaryWorker"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "kms" {
  policy_arn = aws_iam_policy.kms.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_instance_profile" "worker" {
  role = aws_iam_role.worker.name
}
