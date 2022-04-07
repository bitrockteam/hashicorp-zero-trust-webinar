variable "url" {
  default = "http://127.0.0.1:9200"
  #  default = "http://boundary-demo-controller-ec52c62e6a9979ab.elb.us-east-1.amazonaws.com:9200"
}

variable "org" {
  default = "hashicorp-sg"
}


variable "vault_erp_token_for_boundary" {
  sensitive = true
}

variable "vault_token_for_boundary" {
  default   = null
  sensitive = true
}

variable "vault_fqdn" {
  default = "http://127.0.0.1:8200"
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

variable "vault_kv_path_aws" {
  default = "boundary/aws-user"
}

variable "aws_host" {
  default = "13.57.35.149"
}

variable "region" {
  type = string
}

variable "kms_key_id" {
  type = string
}
