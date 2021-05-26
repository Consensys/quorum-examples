package main

import (
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
)

func main() {
	contractAddress := "0x6D19a263c40D5e724D6aEcBf87BD9a3716CC6889"

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
