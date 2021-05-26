package main

import (
	"os"

	"github.com/consensys/quorum-examples/storagecontract"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
)

func main() {
	contractAddress := os.Args[1]
	if len(contractAddress) == 0 {
		println("Please provide a simple storage contract address.")
		return
	}

	// connect to node2
	rpcClient, err := rpc.DialHTTP("http://localhost:22001")
	if err != nil {
		println(err.Error())
		return
	}
	// using node2 tessra 3rd party API
	ethClient, err := ethclient.NewClient(rpcClient).WithPrivateTransactionManager("http://localhost:9082")

	simplestorage, err := storagecontract.NewSimplestorageCaller(common.HexToAddress(contractAddress), ethClient)

	if err != nil {
		print(err.Error())
		return
	}
	val, err := simplestorage.Get(nil)
	if err != nil {
		println(err.Error())
		return
	}
	println("Retrieved value: " + val.String())
}
