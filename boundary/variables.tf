variable "boundary_endpoint" {
  type    = string
  default = null
}

variable "org" {
  default = "hashicorp-sg"
}


variable "vault_erp_token_for_boundary" {
  default   = null
  sensitive = true
}

variable "vault_token_for_boundary" {
  default   = null
  sensitive = true
}

variable "vault_endpoint" {
  type    = string
  default = null
}

variable "vault_psql_dba_path" {
  default = "database/creds/dba"
}

variable "vault_psql_analyst_path" {
  default = "database/creds/analyst"
}

variable "vault_ssh_path" {
  default = "ssh/sign/ubuntu"
}

variable "vault_ssh_otp_path" {
  default = "ssh/creds/otp"
}

variable "rds_host" {
  default = null
}

variable "region" {
  type = string
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "boundary_access_key_id" {
  type    = string
  default = null
}

variable "boundary_secret_access_key" {
  type    = string
  default = null
}


