#!/usr/bin/env bash
PSI=$1
if [[ "$PSI" == "" ]]; then
  echo "Please specify a private state identifier (PSI)"
  exit 1
fi
echo "PSI=$PSI"
NODE_EOA=${2:-0x0}
echo "node.eoa=$NODE_EOA"

curl -k -q -X DELETE https://localhost:4445/clients/$PSI

curl -k -s -X POST https://localhost:4445/clients \
    -H "Content-Type: application/json" \
    --data "{\"grant_types\":[\"client_credentials\"],\"token_endpoint_auth_method\":\"client_secret_post\",\"audience\":[\"Node1\"],\"client_id\":\"$PSI\",\"client_secret\":\"foofoo\",\"scope\":\"rpc://eth_* rpc://quorumExtension_* rpc://rpc_modules psi://$PSI?self.eoa=0x0&node.eoa=$NODE_EOA\"}" | jq .

accessToken=$(curl -k -s -X POST -F "grant_type=client_credentials" -F "client_id=$PSI" -F "client_secret=foofoo" -F "scope=rpc://eth_* rpc://quorumExtension_* rpc://rpc_modules psi://$PSI?self.eoa=0x0&node.eoa=$NODE_EOA" -F "audience=Node1" https://localhost:4444/oauth2/token | jq '.access_token' -r)

geth attach https://localhost:22000?PSI=$PSI --rpcclitls.insecureskipverify --rpcclitoken "bearer $accessToken"