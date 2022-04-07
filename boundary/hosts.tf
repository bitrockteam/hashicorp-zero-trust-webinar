// Prod Support
//
resource "boundary_host_catalog" "my-host-catalog" {
  name     = "SG Host Catalog"
  type     = "static"
  scope_id = boundary_scope.project-prod-support.id
  //scope_id = boundary_scope.org.id
}

// Northwind ERP
//
resource "boundary_host_catalog" "erp-host-catalog" {
  name     = "ERP Host Catalog"
  type     = "static"
  scope_id = boundary_scope.project-northwind-erp.id
}

resource "boundary_host" "rds" {
  name            = "RDS"
  type            = "static"
  address         = var.rds_host != null ? var.rds_host : data.terraform_remote_state.aws.outputs.db_instance_address
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host_set" "rds" {
  name            = "rds set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
  host_ids = [
    boundary_host.rds.id
  ]
}

resource "boundary_host" "rds_erp" {
  name            = "RDS"
  type            = "static"
  address         = var.rds_host != null ? var.rds_host : data.terraform_remote_state.aws.outputs.db_instance_address
  host_catalog_id = boundary_host_catalog.erp-host-catalog.id
}

resource "boundary_host_set" "rds_erp" {
  name            = "rds erp set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.erp-host-catalog.id
  host_ids = [
    boundary_host.rds_erp.id
  ]
}

resource "boundary_host" "aws-demo" {
  name            = "aws-demo"
  type            = "static"
  address         = var.aws_host
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}


resource "boundary_host_set" "aws" {
  name            = "AWS hosts set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
  host_ids = [
    boundary_host.aws-demo.id
  ]
}


resource "boundary_host_catalog_plugin" "aws" {
  scope_id    = boundary_scope.project-prod-support.id
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
    "filters" = "tag:service-type=backend"
  })
}
