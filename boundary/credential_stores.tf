
resource "boundary_credential_store_vault" "vault" {
  name        = "Vault Creds Store"
  description = "Production Vault credential store!"
  address     = var.vault_fqdn
  token       = var.vault_token_for_boundary != null ? var.vault_token_for_boundary : data.terraform_remote_state.vault.outputs.boundary_vault_token
  scope_id    = boundary_scope.project-prod-support.id
  // scope_id    = boundary_scope.org.id
}

resource "boundary_credential_store_vault" "vault-erp" {
  name        = "ERP Vault Creds Store"
  description = "ERP Vault credential store!"
  address     = var.vault_fqdn
  token       = var.vault_erp_token_for_boundary != null ? var.vault_erp_token_for_boundary : data.terraform_remote_state.vault.outputs.boundary_vault_erp_token
  scope_id    = boundary_scope.project-northwind-erp.id
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
  description         = "ERP PSQL "
  credential_store_id = boundary_credential_store_vault.vault-erp.id
  path                = var.vault_psql_analyst_path
  http_method         = "GET"
}


resource "boundary_credential_library_vault" "kv_aws" {
  name                = "KV AWS SSH"
  description         = "KV AWS"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = var.vault_kv_path_aws
  http_method         = "GET"
}

