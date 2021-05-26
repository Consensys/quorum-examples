# Generate go bindings 

Generate go code from solidity code and using it to deploy a simple storage contract.
## Setup
Ensure that you have access to a solidity compiler `solc` and `abigen`.

## Code generation
Invoke:

```shell
abigen --pkg main --type SimpleStorage --out simple_storage.go --solc /usr/local/bin/solc --sol ../../simplestorage.sol
```

The `simple_storage.go` generated code is deliberately omitted so that you invoke `abigen`. If however you are having issues generating the file you can use the `simple_storage.go` from the pregenerated directory.

## Running the example

Start the 7nodes example (make sure the network is started before you try to deploy the simple storage contract).

Invoke:
```shell
go mod download
go run simple_storage.go  simple_storage_deploy.go
```

