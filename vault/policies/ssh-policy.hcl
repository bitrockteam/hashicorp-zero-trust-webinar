path "ssh/roles/*" {
  capabilities = [ "list" ]
}

path "ssh/sign/*" {
  capabilities = ["read","create","update","list","delete"]
}

path "ssh/creds/*" {
  capabilities = ["read","create","update","list","delete"]
}
