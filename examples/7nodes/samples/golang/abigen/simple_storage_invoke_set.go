package main

import (
	"math/big"
	"os"
	"strconv"
	"strings"

	"github.com/consensys/quorum-examples/storagecontract"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
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

	valStr := os.Args[2]
	if len(valStr) == 0 {
		valStr = "5"
	}
	val, err := strconv.ParseInt(valStr, 10, 64)
	if err != nil {
		println("Invalid set value specified. " + err.Error())
		return
	}

	// connect to node1
	rpcClient, err := rpc.DialHTTP("http://localhost:22000")
	if err != nil {
		println(err.Error())
		return
	}

	ethKey := "{\"address\":\"0638e1574728b6d862dd5d3a3e0942c3be47d996\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"d8119d67cb134bc65c53506577cfd633bbbf5acca976cea12dd507de3eb7fd6f\",\"cipherparams\":{\"iv\":\"76e88f3f246d4bf9544448d1a27b06f4\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":262144,\"p\":1,\"r\":8,\"salt\":\"6d05ade3ee96191ed73ea019f30c02cceb6fc0502c99f706b7b627158bfc2b0a\"},\"mac\":\"b39c2c56b35958c712225970b49238fb230d7981ef47d7c33c730c363b658d06\"},\"id\":\"00307b43-53a3-4e03-9d0c-4fcbb3da29df\",\"version\":3}"

	trOpts, err := bind.NewTransactor(strings.NewReader(ethKey), "")
	if err != nil {
		println(err.Error())
		return
	}
	trOpts.GasLimit = 47000000
	// the privacy manager address of node2 (this contract will be deployed from node1 privateFor node2
	trOpts.PrivateFor = []string{"QfeDAys9MPDs2XHExtc84jKGHxZg/aj52DTh0vtA3Xc="}
	// make sure you specify the appropriate privateFrom address (corresponding to your private state/privacy manager)
	trOpts.PrivateFrom = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo="

	// using node1 tessra 3rd party API
	ethClient, err := ethclient.NewClient(rpcClient).WithPrivateTransactionManager("http://localhost:9081")

	simplestorage, err := storagecontract.NewSimplestorageTransactor(common.HexToAddress(contractAddress), ethClient)

	if err != nil {
		print(err.Error())
		return
	}

	transaction, err := simplestorage.Set(trOpts, big.NewInt(val))
	if err != nil {
		print(err.Error())
		return
	}

	println("transactionHash: " + transaction.Hash().Hex())
}
