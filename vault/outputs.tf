output "boundary_vault_token" {
  value     = vault_token.boundary.client_token
  sensitive = true
}

output "boundary_vault_erp_token" {
  value     = vault_token.erp.client_token
  sensitive = true
}

output "boundary_ssh_key_pub" {
  value = trim(tls_private_key.boundary_ssh_key.public_key_openssh, "\n")
}

output "boundary_ssh_key" {
  value     = tls_private_key.boundary_ssh_key.private_key_pem
  sensitive = true
}

output "boundary_signed_cert" {
  value = data.local_file.boundarydemo-signed-cert.content
}
