# The root key used by controllers
resource "aws_kms_key" "root" {
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "root" })
}

# The worker-auth AWS KMS key used by controllers and workers
resource "aws_kms_key" "auth" {
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "worker-auth" })
}

resource "aws_kms_key" "recovery" {
  description             = "Boundary recovery key"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "recovery" })
}
