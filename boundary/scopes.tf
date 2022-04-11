resource "boundary_scope" "global" {
  global_scope = true
  name         = "global"
  scope_id     = "global"
}

// Org scope
//
resource "boundary_scope" "org" {
  name                     = var.org
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

// Project scope
//
resource "boundary_scope" "project_prod_support" {
  name                   = "Production Support"
  description            = "Project for Production Support"
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}

resource "boundary_scope" "project_northwind_erp" {
  name                   = "Northwind ERP"
  description            = "Project for Northwind ERP"
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}
