# Generate go bindings 

Generate go code from solidity code and use it to deploy a simple storage contract.

## Setup
Ensure that you have access to a solidity compiler `solc` and `abigen`.

## Code generation
Invoke:

```shell
> mkdir -p storagecontract
> abigen --pkg storagecontract --type SimpleStorage --out storagecontract/simple_storage.go --solc /usr/local/bin/solc --sol ../../../simplestorage.sol
```

The `simple_storage.go` generated code is deliberately omitted so that you have to invoke `abigen`. If however you are having issues generating the file you can use the `simple_storage.go` from the pregenerated directory.

## Running the example

Start the 7nodes example (make sure the network is started before you try to deploy the simple storage contract).

Ensure all necessary dependencies are available:
```shell
> go mod download
```

To deploy a simple storage contract from `Node1` privateFor `Node2` invoke:
```shell
> go run simple_storage_deploy.go
contractAddress: 0x3f217e1FE69d1B188385b761a2b17827616b9BDB
transactionHash: 0x44633c326086536bc444cfc4401f0394b5692fbe3f38beedd1d73d8e74e0f600
Retrieved value: 123


```

Make a note of the `contractAddress` that is printed in the console.

Using the above contract address check the simple storage contract value on `Node2` (invoke `simpleStorage.get()`).

```shell
> go run simple_storage_invoke_get.go <contractAddress>
Retrieved value: 123
```

Using the above contract address set a new value for the simple storage contract on `Node1` privateFor `Node2` (invoke `simpleStorage.set()`).

```shell
> go run  simple_storage_invoke_set.go <contractAddress> <newValue>
transactionHash: 0xd9ec885e64b8d3480d07d0b439e646153ac3743f163add502854b57be412b1dd
```
