
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

resource "boundary_account" "operation" {
  auth_method_id = boundary_auth_method.password.id
  type           = "password"
  login_name     = "operation"
  password       = "password"
}


resource "boundary_user" "operation" {
  name        = "operation"
  description = "operation's user resource"
  account_ids = [boundary_account.operation.id]
  scope_id    = boundary_scope.org.id
}



resource "boundary_user" "admin" {
  name        = "admin"
  description = "admin's user resource"
  account_ids = [boundary_account.admin.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_account" "admin" {
  auth_method_id = boundary_auth_method.password.id
  type           = "password"
  login_name     = "admin"
  password       = "password"
}
