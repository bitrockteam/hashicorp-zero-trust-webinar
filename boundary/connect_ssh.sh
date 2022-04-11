
set -xe



boundary targets authorize-session -id ttcp_JWStUgEXCY -format=json > authz.json

authz_token=$(cat authz.json | jq -r .item.authorization_token)

#echo "$(cat authz.json | jq -r '.item.credentials[].secret.decoded.signed_key')" > boundarydemo-signed-cert.pub
chmod 600 boundarydemo-signed-cert.pub

boundary connect -authz-token=$authz_token -listen-port=55000 &

sleep 3

ssh -o StrictHostKeyChecking=no -i boundarydemo -i boundarydemo-signed-cert.pub ubuntu@127.0.0.1 -p 55000
