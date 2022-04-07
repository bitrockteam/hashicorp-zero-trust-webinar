resource "vault_policy" "boundary_controller" {
  name = "boundary-controller"

  policy = file("./policies/boundary-controller-policy.hcl")
}

resource "vault_policy" "northwind_database" {
  name = "northwind-database"

  policy = file("./policies/northwind-database-policy.hcl")
}

resource "vault_policy" "ssh" {
  name = "ssh"

  policy = file("./policies/ssh-policy.hcl")
}
