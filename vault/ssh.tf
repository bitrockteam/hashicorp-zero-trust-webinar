resource "vault_mount" "ssh" {
  path = "ssh"
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "foo" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
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

resource "tls_private_key" "boundary_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.boundary_ssh_key.private_key_pem
  filename        = "boundary-ssh-key.pem"
  file_permission = "0600"
}


resource "vault_generic_secret" "ssh_sign" {
  path = "${vault_mount.ssh.path}/sign/${vault_ssh_secret_backend_role.ubuntu.name}"

  disable_read = false

  data_json = jsonencode({
    public_key = trim(tls_private_key.boundary_ssh_key.public_key_openssh, "\n")
  })
}
