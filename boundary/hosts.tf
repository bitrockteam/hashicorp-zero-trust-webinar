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


resource "boundary_host" "localhost" {
  name            = "localhost"
  type            = "static"
  address         = "127.0.0.1"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
}

resource "boundary_host_set" "local" {
  name            = "Local hosts set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.my-host-catalog.id
  host_ids = [
    boundary_host.localhost.id
  ]
}


//
//
resource "boundary_host" "localhost-erp" {
  name            = "localhost-erp"
  type            = "static"
  address         = "127.0.0.1"
  host_catalog_id = boundary_host_catalog.erp-host-catalog.id
}

resource "boundary_host_set" "local-erp" {
  name            = "Local hosts set"
  type            = "static"
  host_catalog_id = boundary_host_catalog.erp-host-catalog.id
  host_ids = [
    boundary_host.localhost-erp.id
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
