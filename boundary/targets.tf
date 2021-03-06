
resource "boundary_target" "ssh-dynamic-aws-target" {
  name         = "SSH Dynamic AWS Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project_prod_support.id
  host_source_ids = [
    boundary_host_set_plugin.backend_vms.id
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.ssh_ubuntu.id
  ]
}

resource "boundary_target" "ssh_otp_dynamic_aws" {
  name         = "SSH OTP Dynamic AWS Target"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.project_prod_support.id
  host_source_ids = [
    boundary_host_set_plugin.otp_vm.id
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.otp_ssh_ubuntu.id
  ]
}

resource "boundary_target" "psql-dba-target" {
  name                     = "PSQL DBA Target"
  type                     = "tcp"
  default_port             = "5432"
  scope_id                 = boundary_scope.project_prod_support.id
  session_connection_limit = -1
  host_source_ids = [
    boundary_host_set_static.rds.id
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.psql_dba.id
  ]
}

resource "boundary_target" "psql-target" {
  name                     = "PSQL Analyst Target"
  type                     = "tcp"
  default_port             = "5432"
  scope_id                 = boundary_scope.project_northwind_erp.id
  session_connection_limit = -1
  host_source_ids = [
    boundary_host_set_static.rds_erp.id
  ]
  application_credential_source_ids = [
    boundary_credential_library_vault.psql_analyst.id
  ]
}
