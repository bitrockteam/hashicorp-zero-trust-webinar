resource "tls_private_key" "boundary_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.boundary_ssh_key.private_key_pem
  filename        = "boundary-ssh-key.pem"
  file_permission = "0600"
}

resource "local_file" "public_ssh_key" {
  content         = tls_private_key.boundary_ssh_key.public_key_openssh
  filename        = "boundary-ssh-key.pub"
  file_permission = "0600"
}
