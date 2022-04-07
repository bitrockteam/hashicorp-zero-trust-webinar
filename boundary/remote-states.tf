data "terraform_remote_state" "vault" {
  backend = "remote"

  config = {
    organization = "bitrock-webinars"
    workspaces = {
      name = "hashicorp-zero-trust-webinar-vault"
    }
  }
}

data "terraform_remote_state" "aws" {
  backend = "remote"

  config = {
    organization = "bitrock-webinars"
    workspaces = {
      name = "hashicorp-zero-trust-webinar-aws"
    }
  }
}
