package main

import (
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
	"os"
)

func main() {
	contractAddress := os.Args[1]
	if len(contractAddress) == 0 {
		println("Please provide a simple storage contract address.")
		return
	}

	// connect to node1
	rpcClient, err := rpc.DialHTTP("http://localhost:22001")
	if err != nil {
		println(err.Error())
		return
	}
	ethClient, err := ethclient.NewClient(rpcClient).WithPrivateTransactionManager("http://localhost:9082")

	simplestorage, err := NewSimplestorageCaller(common.HexToAddress(contractAddress), ethClient)

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
