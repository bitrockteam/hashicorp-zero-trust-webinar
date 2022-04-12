output "boundary_vault_token" {
  value     = vault_token.boundary.client_token
  sensitive = true
}

output "boundary_vault_erp_token" {
  value     = vault_token.erp.client_token
  sensitive = true
}
