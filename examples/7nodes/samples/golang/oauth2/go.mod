module github.com/consensys/quorum-examples

go 1.15

require (
	github.com/ethereum/go-ethereum v1.10.3
	golang.org/x/oauth2 v0.0.0-20210514164344-f6687ab2804c
)

replace github.com/ethereum/go-ethereum => github.com/Consensys/quorum v1.2.2-0.20210518093622-1d7926a19a1e

replace github.com/ethereum/go-ethereum/crypto/secp256k1 => github.com/ConsenSys/quorum/crypto/secp256k1 v0.0.0-20210518093622-1d7926a19a1e
