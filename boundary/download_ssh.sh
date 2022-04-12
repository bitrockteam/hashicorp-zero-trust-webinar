terraform output -raw boundary_ssh_key > boundarydemo
chmod 0600 boundarydemo
terraform output -raw boundary_ssh_key_pub > boundarydemo.pub
chmod 0600 boundarydemo.pub

