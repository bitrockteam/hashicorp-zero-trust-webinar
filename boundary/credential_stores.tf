
resource "boundary_credential_store_vault" "vault" {
  name        = "Vault Creds Store"
  description = "Production Vault credential store!"
  address     = var.vault_endpoint != null ? var.vault_endpoint : data.terraform_remote_state.aws.outputs.vault_endpoint
  token       = var.vault_token_for_boundary != null ? var.vault_token_for_boundary : data.terraform_remote_state.vault.outputs.boundary_vault_token
  scope_id    = boundary_scope.project_prod_support.id
  // scope_id    = boundary_scope.org.id
}

resource "boundary_credential_store_vault" "vault-erp" {
  name        = "ERP Vault Creds Store"
  description = "ERP Vault credential store!"
  address     = var.vault_endpoint != null ? var.vault_endpoint : data.terraform_remote_state.aws.outputs.vault_endpoint
  token       = var.vault_erp_token_for_boundary != null ? var.vault_erp_token_for_boundary : data.terraform_remote_state.vault.outputs.boundary_vault_erp_token
  scope_id    = boundary_scope.project_northwind_erp.id
}


resource "boundary_credential_library_vault" "psql_dba" {
  name                = "PSQL DBA Library"
  description         = "PSQL DBA"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_psql_dba_path
  http_method         = "GET"
}

resource "boundary_credential_library_vault" "psql_analyst" {
  name                = "ERP PSQL Library"
  description         = "ERP PSQL"
  credential_store_id = boundary_credential_store_vault.vault-erp.id
  path                = var.vault_psql_analyst_path
  http_method         = "GET"
}

# https://github.com/hashicorp/boundary/issues/1764
resource "boundary_credential_library_vault" "otp_ssh_ubuntu" {
  name                = "OTP SSH Ubuntu Library"
  description         = "OTP SSH Ubuntu"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_ssh_otp_path
  http_method         = "POST"
}

## public_key below refers to public_key generated from ssh-keygen
# https://github.com/hashicorp/boundary/issues/1768
resource "boundary_credential_library_vault" "ssh_ubuntu" {
  name                = "SSH Ubuntu Library"
  description         = "SSH Ubuntu"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_ssh_path
  http_method         = "POST"
  http_request_body   = <<EOT
    {
      "public_key": "${trim(tls_private_key.boundary_ssh_key.public_key_openssh, "\n")}"
    }
    EOT
}
