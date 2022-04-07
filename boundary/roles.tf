# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the global scope
resource "boundary_role" "global_anon_listing" {
  scope_id = boundary_scope.global.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

# Allows anonymous (un-authenticated) users to list and authenticate against any
# auth method, list the global scope, and read and change password on their account ID
# at the org level scope
resource "boundary_role" "org_anon_listing" {
  scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}


# Creates a role in the global scope that's granting administrative access to
# resources in the org scope for admin user
resource "boundary_role" "org_admin" {
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_user.admin.id
  ]
}


// Organization

resource "boundary_role" "server-admin" {
  name           = "Server Admin Role"
  grant_scope_id = boundary_scope.project-prod-support.id
  grant_strings = [
    "id=${boundary_target.ssh-aws-target.id};actions=*",
    "id=*;type=session;actions=cancel:self,read",
    "id=*;type=*;actions=read,list"
  ]
  scope_id      = boundary_scope.org.id
  principal_ids = [boundary_user.operation.id]
}

// Project
//
resource "boundary_role" "psql-admin" {
  name           = "PSQL Admin Role"
  grant_scope_id = boundary_scope.project-prod-support.id
  grant_strings = [
    "id=${boundary_target.psql-target.id};actions=*",
    "id=*;type=session;actions=cancel:self,read",
    "id=*;type=*;actions=read,list"
  ]
  scope_id      = boundary_scope.org.id
  principal_ids = [boundary_user.dbadmin.id]
}
