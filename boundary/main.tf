provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
	key_id     = "global_root"
  region     = "${var.region}"
  kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}
