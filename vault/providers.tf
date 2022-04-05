
provider "vault" {
  address         = var.vault_endpoint
  token           = data.terraform_remote_state.aws.outputs.vault_token
  skip_tls_verify = var.vault_skip_tls_verify
  ca_cert_file    = var.ca_cert_file
}
