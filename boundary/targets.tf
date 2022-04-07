resource "boundary_target" "ssh-aws-target" {
  name         = "SSH AWS Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project-prod-support.id
  host_source_ids = [
    boundary_host_set.aws.id
  ]
  application_credential_source_ids = [
    //todo
    boundary_credential_library_vault.kv_aws.id
  ]
}

resource "boundary_target" "ssh-dynamic-aws-target" {
  name         = "SSH Dynamic AWS Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project-prod-support.id
  host_source_ids = [
    boundary_host_set_plugin.backend_vms.id
  ]
  #  application_credential_source_ids = [
  #    //todo
  #    boundary_credential_library_vault.kv_aws.id
  #  ]
}

resource "boundary_target" "psql-dba-target" {
  name                     = "PSQL DBA Target"
  type                     = "tcp"
  default_port             = "5432"
  scope_id                 = boundary_scope.project-prod-support.id
  session_connection_limit = -1
  host_source_ids = [
    boundary_host_set.rds.id
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.psql_dba.id
  ]
}

resource "boundary_target" "psql-target" {
  name                     = "PSQL Analyst Target"
  type                     = "tcp"
  default_port             = "5432"
  scope_id                 = boundary_scope.project-northwind-erp.id
  session_connection_limit = -1
  host_source_ids = [
    boundary_host_set.rds_erp.id
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.psql_analyst.id
  ]
}
