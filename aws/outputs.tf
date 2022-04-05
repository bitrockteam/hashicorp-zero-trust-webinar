output "dns_name" {
  description = "The public DNS name of the controller load balancer"
  value       = module.alb.lb_dns_name
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "ssh_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "vault_token" {
  value     = module.vault_cluster.vault_token
  sensitive = true
}
