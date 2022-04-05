module "aws" {
  source = "./aws"
  region = var.region
}

module "boundary" {
  source     = "./boundary"
  url        = "http://${module.aws.boundary_lb}:9200"
  target_ips = module.aws.target_ips
}

provider "aws" {
  region = var.region
}

provider "boundary" {
  addr             = "http://${module.aws.boundary_lb}:9200"
  recovery_kms_hcl = <<EOT
kms "awskms" {
	purpose    = "recovery"
  region     = "${var.region}"
  kms_key_id = "${module.aws.kms_recovery_key_id}"
}
EOT
}
