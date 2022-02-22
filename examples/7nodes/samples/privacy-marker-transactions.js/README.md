# Examples of Privacy Marker Transactions

These examples demonstrate javascript code for creating a private contract, created using [Privacy Marker Transactions](https://docs.goquorum.consensys.net/en/latest/Concepts/Privacy/PrivacyMarkerTransactions/).

## Running

Please ensure that your sample network has privacy marker transactions enabled (the config section in the genesis.json has the `"privacyPrecompileBlock": 0` element and geth command line arguments include `--privacymarker.enable`). 

### Raw transactions

Run the example:

```shell script
$ node send-private-txn-pmt.js 
```

### Externally signed transactions

Run the example:

```shell script
$ node send-externally-signed-private-txn-pmt.js 
```
