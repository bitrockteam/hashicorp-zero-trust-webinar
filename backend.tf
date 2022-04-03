terraform {
  backend "remote" {

    hostname     = "app.terraform.io"
    organization = "bitrock-webinars"

    workspaces {
      name = "hashicorp-zero-trust-webinar"
    }
  }
}