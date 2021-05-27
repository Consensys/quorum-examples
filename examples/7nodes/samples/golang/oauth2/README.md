# Connect to go-quorum using oauth2 token 

## Setup

Start the quorum-examples multitenant network using `docker-compose`:
```shell
> docker-compose -f docker-compose-4nodes-mt.yml up -d
```

Define the PS1 tenant in the oauth2 server:
```shell
> curl -k -s -X POST https://localhost:4445/clients -H "Content-Type: application/json" --data "{\"grant_types\":[\"client_credentials\"],\"token_endpoint_auth_method\":\"client_secret_post\",\"audience\":[\"Node1\"],\"client_id\":\"PS1\",\"client_secret\":\"foofoo\",\"scope\":\"rpc://eth_* rpc://quorumExtension_* rpc://rpc_modules psi://PS1?self.eoa=0x0&node.eoa=0x0\"}"
```

## Connect to tenant PS1 

Connect to tenant PS1 and retrieve the current block height using `eth_blockNumber`:

```shell
> go run connect-oauth2-token.go
Block number: 0x3
```