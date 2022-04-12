output "dns_name" {
  description = "The public DNS name of the controller load balancer"
  value       = module.alb.lb_dns_name
}

output "vault_endpoint" {
  value = "http://${module.alb.lb_dns_name}:8200"
}

output "boundary_endpoint" {
  value = "http://${module.alb.lb_dns_name}"
}

output "postgres_endpoint" {
  value = module.postgresql.db_instance_endpoint
}

output "db_instance_address" {
  value = module.postgresql.db_instance_address
}

output "postgres_username" {
  value     = module.postgresql.db_instance_username
  sensitive = true
}

output "postgres_password" {
  value     = module.postgresql.db_instance_password
  sensitive = true
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "ssh_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ssh_ca_key" {
  value     = tls_private_key.ssh_ca_key.private_key_pem
  sensitive = true
}

output "ssh_ca_key_pub" {
  value = tls_private_key.ssh_ca_key.public_key_openssh
}

output "vault_token" {
  value     = module.vault_cluster.vault_token
  sensitive = true
}

output "boundary_access_key_id" {
  value = aws_iam_access_key.boundary.id
}

output "boundary_secret_access_key" {
  value     = aws_iam_access_key.boundary.secret
  sensitive = true
}

output "otp_vm_private_ip" {
  value = aws_instance.boundary_otp_instance.private_ip
}
