// Prod Support
//
resource "boundary_host_catalog_static" "my_host_catalog" {
  name     = "SG Host Catalog"
  scope_id = boundary_scope.project_prod_support.id
  //scope_id = boundary_scope.org.id
}

// Northwind ERP
//
resource "boundary_host_catalog_static" "erp_host_catalog" {
  name     = "ERP Host Catalog"
  scope_id = boundary_scope.project_northwind_erp.id
}

resource "boundary_host_static" "rds" {
  name            = "RDS"
  address         = var.rds_host != null ? var.rds_host : data.terraform_remote_state.aws.outputs.db_instance_address
  host_catalog_id = boundary_host_catalog_static.my_host_catalog.id
}

resource "boundary_host_set_static" "rds" {
  name            = "rds set"
  host_catalog_id = boundary_host_catalog_static.my_host_catalog.id
  host_ids = [
    boundary_host_static.rds.id
  ]
}

resource "boundary_host_static" "rds_erp" {
  name            = "RDS"
  address         = var.rds_host != null ? var.rds_host : data.terraform_remote_state.aws.outputs.db_instance_address
  host_catalog_id = boundary_host_catalog_static.erp_host_catalog.id
}

resource "boundary_host_set_static" "rds_erp" {
  name            = "rds erp set"
  host_catalog_id = boundary_host_catalog_static.erp_host_catalog.id
  host_ids = [
    boundary_host_static.rds_erp.id
  ]
}


resource "boundary_host_catalog_plugin" "aws" {
  scope_id    = boundary_scope.project_prod_support.id
  name        = "AWS Plugin"
  plugin_name = "aws"
  attributes_json = jsonencode({
    "disable_credential_rotation" = true
    "region"                      = var.region
  })
  secrets_json = jsonencode({
    "access_key_id"     = var.boundary_access_key_id != null ? var.boundary_access_key_id : data.terraform_remote_state.aws.outputs.boundary_access_key_id
    "secret_access_key" = var.boundary_secret_access_key != null ? var.boundary_secret_access_key : data.terraform_remote_state.aws.outputs.boundary_secret_access_key
  })
}

resource "boundary_host_set_plugin" "backend_vms" {
  name            = "backend vm set"
  host_catalog_id = boundary_host_catalog_plugin.aws.id
  attributes_json = jsonencode({
    "filters" = [
      "tag:service-type=backend",
      "tag:application=users"
    ]
  })
}
