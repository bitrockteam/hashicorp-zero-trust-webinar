output "boundary_vault_token" {
  value     = vault_token.boundary.client_token
  sensitive = true
}

output "boundary_vault_erp_token" {
  value     = vault_token.erp.client_token
  sensitive = true
}

output "boundary_ssh_key_pub" {
  value = tls_private_key.boundary_ssh_key.public_key_pem
}

output "ssh" {
  value = vault_generic_secret.ssh
}
