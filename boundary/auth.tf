resource "boundary_auth_method" "password" {
  name        = "password_auth_method"
  description = "Password auth method"
  type        = "password"
  scope_id    = boundary_scope.org.id
}
