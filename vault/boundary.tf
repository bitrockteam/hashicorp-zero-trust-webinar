resource "vault_token" "boundary" {
  no_default_policy = true
  policies          = ["boundary-controller", "northwind-database"]

  renewable = true
  period    = "20m"
}
