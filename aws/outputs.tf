output "dns_name" {
  description = "The public DNS name of the controller load balancer"
  value       = module.alb.lb_dns_name
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}
