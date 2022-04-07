
resource "boundary_account" "dbadmin" {
  auth_method_id = boundary_auth_method.password.id
  type           = "password"
  login_name     = "dbadmin"
  password       = "password"
}


resource "boundary_user" "dbadmin" {
  name        = "dbadmin"
  description = "dbadmin's user resource"
  account_ids = [boundary_account.dbadmin.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_account" "ops" {
  auth_method_id = boundary_auth_method.password.id
  type           = "password"
  login_name     = "ops"
  password       = "password"
}


resource "boundary_user" "ops" {
  name        = "ops"
  description = "ops's user resource"
  account_ids = [boundary_account.ops.id]
  scope_id    = boundary_scope.org.id
}

