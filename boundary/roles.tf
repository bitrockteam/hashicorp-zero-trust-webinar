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

# Adds a read-only role in the global scope granting read-only access
# to all resources within the org scope
resource "boundary_role" "org_readonly" {
  name        = "readonly"
  description = "Read-only role"
  principal_ids = [
    boundary_user.operation.id,
    boundary_user.dbadmin.id
  ]
  grant_strings = [
    "id=*;type=*;actions=read"
  ]
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
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


# Adds an org-level role granting administrative permissions within the projects
resource "boundary_role" "project_erp_admin" {
  name           = "project_erp_admin"
  description    = "Administrator role for northwind erp"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project-northwind-erp.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_user.admin.id
  ]
}

resource "boundary_role" "project_prod_support" {
  name           = "project_prod_support"
  description    = "Administrator role for prod support"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project-prod-support.id
  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = [
    boundary_user.admin.id
  ]
}

resource "boundary_role" "server-admin" {
  name           = "Server Admin Role"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project-prod-support.id
  grant_strings = [
    "id=${boundary_target.ssh-aws-target.id};type=*;actions=*",
    "id=*;type=session;actions=cancel:self,read",
    "id=*;type=*;actions=read,list"
  ]
  principal_ids = [boundary_user.operation.id]
}

// Project
//
resource "boundary_role" "psql-admin" {
  name           = "PSQL Admin Role"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.project-prod-support.id
  grant_strings = [
    "id=${boundary_target.psql-dba-target.id};actions=*",
    "id=*;type=session;actions=cancel:self,read",
    "id=*;type=*;actions=read,list"
  ]
  principal_ids = [boundary_user.dbadmin.id]
}
