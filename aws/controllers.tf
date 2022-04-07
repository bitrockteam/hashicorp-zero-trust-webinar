
locals {
  controller_configuration = templatefile(
    "${path.module}/templates/controller.hcl.tpl",
    {
      # Database URL for PostgreSQL
      database_url = format(
        "postgresql://%s:%s@%s/%s",
        module.postgresql.db_instance_username,
        module.postgresql.db_instance_password,
        module.postgresql.db_instance_endpoint,
        module.postgresql.db_instance_name
      )

      tls_disabled  = var.tls_disabled
      tls_cert_path = var.tls_cert_path
      tls_key_path  = var.tls_key_path

      keys = [
        {
          key_id  = aws_kms_key.root.key_id
          purpose = "root"
        },
        {
          key_id  = aws_kms_key.auth.key_id
          purpose = "worker-auth"
        },
        {
          key_id  = aws_kms_key.recovery.key_id
          purpose = "recovery"
        }

      ]
    }
  )
}

data "aws_instances" "controllers" {
  instance_state_names = ["running"]

  instance_tags = {
    "aws:autoscaling:groupName" = module.controllers.auto_scaling_group_name
  }
}

data "aws_s3_bucket" "boundary" {
  bucket = aws_s3_bucket.boundary.id
}

resource "aws_security_group" "alb" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  dynamic "ingress" {
    for_each = [80, 443, 8200]

    content {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = ingress.value
      protocol    = "TCP"
      to_port     = ingress.value
    }
  }

  name = "Boundary Application Load Balancer"

  tags = merge(
    {
      Name = "Boundary Application Load Balancer"
    },
    var.tags
  )

  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

resource "aws_security_group" "controller" {
  name   = "Boundary controller"
  tags   = var.tags
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

resource "aws_security_group_rule" "ssh" {
  from_port                = 22
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = one(aws_security_group.bastion[*].id)
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress" {
  from_port                = 9200
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.alb.id
  to_port                  = 9200
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.controller.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group" "postgresql" {
  ingress {
    from_port       = 5432
    protocol        = "TCP"
    security_groups = [aws_security_group.controller.id, aws_security_group.internal_vault.id, aws_security_group.worker.id, aws_security_group.bastion.id]
    to_port         = 5432
  }

  tags   = var.tags
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.5"

  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    },
    {
      port     = 8200
      protocol = "HTTP"
    }
  ]

  load_balancer_type = "application"
  name               = "boundary"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnets
  tags               = var.tags

  target_groups = [
    {
      name             = "boundary"
      backend_protocol = "HTTP"
      backend_port     = 9200
    },
    {
      name             = "vault"
      backend_protocol = "HTTP"
      backend_port     = 8200
      health_check = {
        protocol = "HTTP"
        matcher  = "200"
        path     = "/v1/sys/leader"
      }
      targets = {
        vault_1 = {
          target_id = aws_instance.vault_cluster[0].id
          port      = 8200
        },
        vault_2 = {
          target_id = aws_instance.vault_cluster[1].id
          port      = 8200
        },
        vault_3 = {
          target_id = aws_instance.vault_cluster[2].id
          port      = 8200
        }
      }
    },
  ]

  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

resource "random_password" "postgresql" {
  length  = 16
  special = false
}

module "postgresql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.4"

  allocated_storage       = 5
  backup_retention_period = 0
  backup_window           = "03:00-06:00"
  engine                  = "postgres"
  engine_version          = "14.1"
  family                  = "postgres14"
  identifier              = "boundary"
  instance_class          = "db.t3.micro"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  major_engine_version    = "14"
  name                    = "boundary"
  password                = random_password.postgresql.result
  port                    = 5432
  storage_encrypted       = false
  subnet_ids              = local.private_subnets
  tags                    = var.tags
  username                = "boundary"
  vpc_security_group_ids  = [aws_security_group.postgresql.id]
}

module "controllers" {
  source = "git::https://github.com/jasonwalsh/terraform-aws-boundary//modules/boundary?ref=refs/tags/v1.1.5"

  after_start = [
    "grep 'Initial auth information' /var/log/cloud-init-output.log && aws s3 cp /var/log/cloud-init-output.log s3://${aws_s3_bucket.boundary.id}/{{v1.local_hostname}}/cloud-init-output.log || true"
  ]

  auto_scaling_group_name = "BoundaryController"

  # Initialize the DB before starting the service and install the AWS
  # CLI.
  before_start = [
    "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
    "unzip awscliv2.zip",
    "./aws/install",
    "boundary database init -config /etc/boundary/configuration.hcl -log-format json"
  ]

  boundary_release     = var.boundary_release
  bucket_name          = aws_s3_bucket.boundary.id
  desired_capacity     = var.controller_desired_capacity
  iam_instance_profile = aws_iam_instance_profile.controller.arn
  image_id             = local.image_id
  instance_type        = var.controller_instance_type
  key_name             = aws_key_pair.bitrock.key_name
  max_size             = var.controller_max_size
  min_size             = var.controller_min_size
  security_groups      = [aws_security_group.controller.id]
  tags                 = var.tags
  target_group_arns    = [module.alb.target_group_arns[0]]
  vpc_zone_identifier  = local.private_subnets

  write_files = [
    {
      content     = local.controller_configuration
      owner       = "root:root"
      path        = "/etc/boundary/configuration.hcl"
      permissions = "0644"
    }
  ]
}

# https://www.boundaryproject.io/docs/configuration/kms/awskms#authentication
#
# Allows the controllers to invoke the Decrypt, DescribeKey, and Encrypt
# routines for the worker-auth and root keys.
data "aws_iam_policy_document" "controller" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt"
    ]

    effect = "Allow"

    resources = [aws_kms_key.auth.arn, aws_kms_key.root.arn, aws_kms_key.recovery.arn]
  }

  statement {
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    resources = [
      "${data.aws_s3_bucket.boundary.arn}/",
      "${data.aws_s3_bucket.boundary.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "controller" {
  name   = "BoundaryControllerServiceRolePolicy"
  policy = data.aws_iam_policy_document.controller.json
}

resource "aws_iam_role" "controller" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "ServiceRoleForBoundaryController"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "controller" {
  policy_arn = aws_iam_policy.controller.arn
  role       = aws_iam_role.controller.name
}

resource "aws_iam_instance_profile" "controller" {
  role = aws_iam_role.controller.name
}

resource "aws_security_group" "bastion" {

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
  }

  name   = "Boundary Bastion"
  tags   = var.tags
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

resource "aws_instance" "bastion" {

  ami                         = local.image_id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.bitrock.key_name
  subnet_id                   = local.public_subnets[0]
  tags                        = merge(var.tags, { Name = "Boundary Bastion" })
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  provisioner "file" {
    source      = "sql"
    destination = "~/"
  }
}
