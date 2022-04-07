listener "tcp" {
  address     = "{{ds.meta_data.local_ipv4}}:9202"
	purpose = "proxy"
%{ if tls_disabled == true }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}"  
  tls_key_file  = "${tls_key_path}"
%{ endif }

	#proxy_protocol_behavior = "allow_authorized"
	#proxy_protocol_authorized_addrs = "127.0.0.1"
}

worker {
  # Name attr must be unique
  public_addr = "{{ds.meta_data.public_ipv4}}"
	name = "demo-worker-{{v1.local_hostname}}"
	description = "A default worker created for demonstration"
	controllers = ${controllers}
}

disable_mlock = true

%{ for key in keys ~}
kms "awskms" {
  kms_key_id = "${key["key_id"]}"
  purpose    = "${key["purpose"]}"
}

%{ endfor ~}

