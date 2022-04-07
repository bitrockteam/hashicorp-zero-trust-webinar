resource "vault_token" "boundary" {
  no_default_policy = true
  policies          = ["boundary-controller", "northwind-database", "ssh-policy"]

  renewable = true
  no_parent = true
  period    = "765h"
}

resource "vault_token" "erp" {
  no_default_policy = true
  policies          = ["boundary-controller", "northwind-database", "ssh-policy"]

  renewable = true
  no_parent = true
  period    = "765h"
}
