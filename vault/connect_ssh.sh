#!/usr/bin/env bash

set -xe

boundary targets authorize-session -id ttcp_JWStUgEXCY -format=json > authz.json

authz_token=$(cat authz.json | jq -r .item.authorization_token)

pub_key=$(cat authz.json | jq -r '.item.credentials[].secret.decoded.signed_key')
echo "$pub_key" > boundarydemo-cert.pub
chmod 0600 boundarydemo-cert.pub

boundary connect -authz-token=$authz_token -listen-port=55000 &

sleep 1

ssh -vvv -o StrictHostKeyChecking=no  -i boundarydemo -i boundarydemo-cert.pub ubuntu@127.0.0.1 -p 55000
