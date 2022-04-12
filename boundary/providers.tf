provider "boundary" {
  addr             = var.boundary_endpoint != null ? var.boundary_endpoint : data.terraform_remote_state.aws.outputs.boundary_endpoint
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
  region     = "${var.region}"
  kms_key_id = "${var.kms_key_id != null ? var.kms_key_id : data.terraform_remote_state.aws.outputs.kms_recovery_key_id}"
}
EOT
}
