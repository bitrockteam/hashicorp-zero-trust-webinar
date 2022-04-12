// Common args
variable "vault_endpoint" {
  type    = string
  default = null
}

variable "vault_token" {
  type    = string
  default = null
}

variable "vault_skip_tls_verify" {
  type    = bool
  default = false
}

// Extra
variable "ca_cert_file" {
  type    = string
  default = null
}
