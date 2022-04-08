terraform output -raw boundary_ssh_key > boundarydemo
terraform output -raw boundary_ssh_key_pub > boundarydemo.pub
terraform output -raw boundary_signed_cert > boundarydemo-signed-cert.pub

