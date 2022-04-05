data "terraform_remote_state" "bootstrap" {
  backend = "remote"

  config = {
    organization = "bitrock-webinars"
    workspaces = {
      name = "hashicorp-zero-trust-webinar-aws"
    }
  }
}
