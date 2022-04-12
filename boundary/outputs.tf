output "target-ids" {
  value = [
    "AWS VM: ${boundary_target.ssh-dynamic-aws-target.id}",
    "POSTGRES-DBA: ${boundary_target.psql-dba-target.id}",
    "POSTGRES: ${boundary_target.psql-target.id}",
  ]
}

output "dbadmin-password" {
  value = [boundary_account.dbadmin.login_name, boundary_account.dbadmin.password]
}

output "auth-method" {
  value = [
    "PASSWORD: ${boundary_auth_method.password.id}"
  ]
}

output "boundary_ssh_key_pub" {
  value = trim(tls_private_key.boundary_ssh_key.public_key_openssh, "\n")
}

output "boundary_ssh_key" {
  value     = tls_private_key.boundary_ssh_key.private_key_pem
  sensitive = true
}
