resource "vault_mount" "ssh" {
  path = "ssh"
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "foo" {
  backend     = vault_mount.ssh.path
  private_key = data.terraform_remote_state.aws.outputs.ssh_ca_key
  public_key  = data.terraform_remote_state.aws.outputs.ssh_ca_key_pub
}

resource "vault_ssh_secret_backend_role" "ubuntu" {
  name                    = "ubuntu"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  default_user            = "ubuntu"
  allowed_users           = "ubuntu"
  ttl                     = "3600"
  default_extensions = {
    "permit-pty" : ""
  }

}

#
#resource "null_resource" "ssh_sign" {
#  triggers = {
#    pub        = md5(local_file.public_ssh_key.content)
#    always_run = timestamp()
#  }
#
#  provisioner "local-exec" {
#    command = "wget https://releases.hashicorp.com/vault/1.10.0/vault_1.10.0_linux_amd64.zip && unzip vault_1.10.0_linux_amd64.zip && ./vault write -field=signed_key ${vault_mount.ssh.path}/sign/${vault_ssh_secret_backend_role.ubuntu.name} public_key=@${local_file.public_ssh_key.filename} > boundarydemo-signed-cert.pub"
#    environment = {
#      VAULT_ADDR  = var.vault_endpoint != null ? var.vault_endpoint : data.terraform_remote_state.aws.outputs.vault_endpoint
#      VAULT_TOKEN = data.terraform_remote_state.aws.outputs.vault_token
#    }
#  }
#}
#
#data "local_file" "boundarydemo-signed-cert" {
#  filename = "boundarydemo-signed-cert.pub"
#
#  depends_on = [
#    null_resource.ssh_sign
#  ]
#}
