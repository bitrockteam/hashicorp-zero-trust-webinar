disable_mlock = true

telemetry { 
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

controller {
  name        = "controller"
  description = "A controller for a demo!"

  database {
    url = "${database_url}"
  }
}


disable_mlock = true



listener "tcp" {
  address                           = "{{ds.meta_data.local_ipv4}}:9200"
	purpose                           = "api"
%{ if tls_disabled == true }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}"  
  tls_key_file  = "${tls_key_path}"
%{ endif }
	# proxy_protocol_behavior         = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
	cors_enabled                      = true
	cors_allowed_origins              = ["*"]
}

listener "tcp" {
  address                           = "{{ds.meta_data.local_ipv4}}:9201"
	purpose                           = "cluster"
%{ if tls_disabled == true }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}"  
  tls_key_file  = "${tls_key_path}"
%{ endif }
	# proxy_protocol_behavior         = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
}
%{ for key in keys ~}
kms "awskms" {
  kms_key_id = "${key["key_id"]}"
  purpose    = "${key["purpose"]}"
}

%{ endfor ~}
