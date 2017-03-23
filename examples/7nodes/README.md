# 7 nodes

This example configures 7 nodes, each with their own PrivateTransactionManager. Usage:

  - `init.sh`: Initialize accounts and keystores
  - `start.sh`: Launch `constellation` and `geth` nodes, then send a private transaction
  - `stop.sh`: Stop all `constellation` and `geth` nodes

There are corresponding commands for running in Raft mode (`stop.sh` stays the same).

  - `raft-init.sh`
  - `raft-start.sh`

All logs and temporary data will be written to the `qdata` folder.

## Testing Privacy
You can run the 7node example to test the privacy features of Quorum. As described in the Quick Start section of the [README](https://github.com/jpmorganchase/quorum), the final step of the 7node `start.sh` script was the sending of a private transaction to generate a (private) smart contract (SimpleStorage) sent from node 1 "for" node 7 (denoted by the public key passed via privateFor: ["ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="] in the sendTransaction call). We'll begin by demonstrating only nodes 1 and 7 are able to view the initial state of the contract. Next we have node 1 update the state of this contract and again verify only nodes 1 and 7 are able to see the updated state of the contract after the block containing the update transaction is validated by the network.

For this test it is recommended to use separate terminal windows running geth JavaScript console attached to node 1, node 7, and any node 2-6 (in our example we'll choose node 4).

In each terminal, ensure you are in the 7nodes dir before running the below.

* If you aren't already running the 7nodes example, in terminal 1 run ``$ ./init.sh `` followed by ``$ ./start.sh ``
* In terminal 1 run ``$ geth attach ipc:qdata/dd1/geth.ipc``
* In terminal 2 run ``$ geth attach ipc:qdata/dd4/geth.ipc``
* In terminal 3 run ``$ geth attach ipc:qdata/dd7/geth.ipc``

For each of the 3 nodes we'll use the built-in JavaScript by setting the variable ```address``` assigned to the simpleStorage contract address created by the node 1. The address can be found in the node 1's log file 7nodes/qdata/logs/1.log, or alternatively by reading the `contractAddress` param after calling `eth.getTransactionReceipt(txHash)` ([Ethereum API documentation](https://github.com/ethereum/wiki/wiki/JavaScript-API#web3ethgettransactionreceipt)), passing in the transaction hash that was logged in the console that you ran the 7nodes example in. Replace the address below with the address value found in the 1.log file:
```
> var address = "0x1932c48b2bf8102ba33b4a6b545c32236e342f34";
```
Next we'll use ```eth.contract``` to define a contract class with the simpleStorage ABI definition as follows:
```
> var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"type":"constructor"}];
> var private = eth.contract(abi).at(address)
```
The function calls are now available on the contract instance and you can call those methods on the contract. Let's start by examining the initial value of the contract to make sure that only nodes 1 and 7 can see the initialized value.
* In terminal window 1 (node 1)
```
> private.get()
42
```
* In terminal window 2 (node 4)
```
> private.get()
0
```
* In terminal window 3 (node 7)
```
> private.get()
42
```

So we now see nodes 1 and 7 are able to read the state of the private contract and it's initial value is 42. Node 4 is unable to read the state. Next we'll have node 1 set the state to the value `4` and verify only nodes 1 and 7 are able to view the new state.

In terminal window 1 (node 1)
```
> private.set(4,{from:eth.coinbase,privateFor:["ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="]});
"0xacf293b491cccd1b99d0cfb08464a68791cc7b5bc14a9b6e4ff44b46889a8f70"
```
You can check the log files in ~7nodes/qdata/logs directory to see each node validating the block with this new private transaction. Once the block containing the transaction has been validated we can once again check the state from each node 1, 4, and 7.
* In terminal window 1 (node 1)
```
> private.get()
4
```
* In terminal window 2 (node 4)
```
> private.get()
0
```
* In terminal window 3 (node 7)
```
> private.get()
4
```
And there you have it. All 7 nodes are validating the same blockchain of transactions, the private transactions carrying nothing other than a 512 bit hash, and only parties to private transactions are able to view and update the state of private contracts.
