resource "vault_mount" "db" {
  path = "database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "northwind" {
  backend       = vault_mount.db.path
  name          = "northwind"
  allowed_roles = ["dba", "analyst"]

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@localhost:16001/postgres?sslmode=disable"
    username       = "vault"
    password       = "vault-password"
  }
}

resource "vault_database_secret_backend_role" "dba" {
  backend             = vault_mount.db.path
  name                = "dba"
  db_name             = vault_database_secret_backend_connection.northwind.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' inherit; grant northwind_dba to \"{{name}}\";"]
  default_ttl         = 180
  max_ttl             = 3600
}

resource "vault_database_secret_backend_role" "analyst" {
  backend             = vault_mount.db.path
  name                = "analyst"
  db_name             = vault_database_secret_backend_connection.northwind.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' inherit; grant northwind_analyst to \"{{name}}\";"]
  default_ttl         = 180
  max_ttl             = 3600
}
