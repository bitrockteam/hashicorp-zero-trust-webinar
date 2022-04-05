provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
  region     = "${var.region}"
  kms_key_id = "${var.kms_key_id}"
}
EOT
}
