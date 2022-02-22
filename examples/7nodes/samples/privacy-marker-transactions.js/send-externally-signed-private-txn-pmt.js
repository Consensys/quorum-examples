/*
 * Example of creating a contract, using an externally signed privacy marker transaction.
 */

const ethereumjsTx = require('ethereumjs-tx');
const Web3 = require("web3");
// TODO: this example requires a web3j-quorum release with recent changes on master to add PMT support.
//  Until a release is available with those, you need to build web3j-quorum from master and use:
//      const Web3Quorum = require("/path/to/local/web3js-quorum");
const Web3Quorum = require("web3js-quorum");

const web3 = new Web3Quorum(
  new Web3("http://localhost:22000"),
  {
    privateUrl: "http://localhost:9081",
  },
  true
);

const TM3_PUBLIC_KEY = "1iTZde/ndBHvzhcl7V68x44Vx7pl8nwx9LqnM/AfJUg=";
const TM7_PUBLIC_KEY = "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=";

const decryptedAcc = web3.eth.accounts.decrypt({"address":"ed9d02e382b34818e88b88a309c7fe71e65f419d","crypto":{"cipher":"aes-128-ctr","ciphertext":"4e77046ba3f699e744acb4a89c36a3ea1158a1bd90a076d36675f4c883864377","cipherparams":{"iv":"a8932af2a3c0225ee8e872bc0e462c11"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"8ca49552b3e92f79c51f2cd3d38dfc723412c212e702bd337a3724e8937aff0f"},"mac":"6d1354fef5aa0418389b1a5d1f5ee0050d7273292a1171c51fd02f9ecff55264"},"id":"a65d1ac3-db7e-445d-a1cc-b6c5eeaa05e0","version":3}, "");

const simpleStorageDeploy =
    "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";

const abi = [
  {
    constant: true,
    inputs: [],
    name: "storedData",
    outputs: [{ name: "", type: "uint256" }],
    payable: false,
    type: "function",
  },
  {
    constant: false,
    inputs: [{ name: "x", type: "uint256" }],
    name: "set",
    outputs: [],
    payable: false,
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "get",
    outputs: [{ name: "retVal", type: "uint256" }],
    payable: false,
    type: "function",
  },
  {
    inputs: [{ name: "initVal", type: "uint256" }],
    payable: false,
    type: "constructor",
  },
];

const simpleContract = new web3.eth.Contract(abi);

const bytecodeWithInitParam = simpleContract
    .deploy({ data: simpleStorageDeploy, arguments: [42] })
    .encodeABI();

(async () => {
    try {
        //Note: pmt and private txn must use same nonce value
        const nonce = await web3.eth.getTransactionCount(decryptedAcc.address, "pending");
        console.log("Will use nonce value: ", nonce);

        //
        //Store private payload in tessera (calls '/storeraw' and returns tessera hash)
        //
        const storeRawArgs = {
            data: bytecodeWithInitParam
        };
        web3.ptm.storeRaw(storeRawArgs)
            .then(tesseraPayloadHash => {
                console.log("Stored private data in local Tessera, hash: ", tesseraPayloadHash);

                //
                //Create the private txn, sign it, serialize it and mark it as private
                //
                console.log("Creating private txn with nonce: ", nonce);
                const txnParams = {
                    gasPrice: 0,
                    gasLimit: 4300000,
                    value: 0,
                    data: '0x' + tesseraPayloadHash,
                    //### from: decryptedAcc.address,
                    from: TM7_PUBLIC_KEY,
                    nonce: nonce
                };
                const txn = new ethereumjsTx(txnParams);
                txn.sign(Buffer.from(decryptedAcc.privateKey.substring(2), "hex"))
                signedTxHex = '0x' + txn.serialize().toString('hex');
                const privateSignedTx = web3.utils.setPrivate(signedTxHex)
                const privateSignedTxHex = `0x${privateSignedTx.toString("hex")}`;

                //
                //Send private transaction to quorum for distribution to participants
                //
                web3.eth.distributePrivateTransaction(privateSignedTxHex, {privateFrom: TM7_PUBLIC_KEY, privateFor: [TM3_PUBLIC_KEY]})
                    .then(tesseraPrivTxnHash => {
                        console.log("Stored private transaction in local Tessera, hash: ", tesseraPrivTxnHash);

                        web3.eth.getPrivacyPrecompileAddress()
                            .then(precompileAddress => {
                                console.log("Got precompile address: ", precompileAddress);

                                //
                                //Create private marker transaction (PMT), sign it and serialize it
                                //
                                pmtData = decryptedAcc.address.concat(tesseraPrivTxnHash.substring(2));
                                const txnParams = {
                                    gasPrice: 0,
                                    gasLimit: 4300000,
                                    value: 0,
                                    data: pmtData,
                                    from: decryptedAcc.address,
                                    to: precompileAddress,
                                    nonce: nonce
                                };
                                const txn = new ethereumjsTx(txnParams);
                                txn.sign(Buffer.from(decryptedAcc.privateKey.substring(2), "hex"))
                                signedTxHex = '0x' + txn.serialize().toString('hex');

                                //
                                //Now send the signed PMT to quorum
                                //
                                console.log("Sending signed privacy marker transaction to quorum, with nonce");
                                web3.eth.sendSignedTransaction(signedTxHex)
                                    .then(pmtReceipt => {
                                        console.log("PMT RECEIPT: ", pmtReceipt);

                                        web3.eth.getPrivateTransactionReceipt(pmtReceipt.transactionHash)
                                            .then(receipt => {
                                                console.log("PRIVATE TXN RECEIPT: ", receipt);
                                                contractAddressPrivate = receipt.contractAddress;
                                                console.log("contract address: ", receipt.contractAddress);
                                            })
                                            .catch(error => {
                                                console.log("ERROR: getPrivateTransactionReceipt() failed: ", error)
                                            });
                                    })
                                    .catch(error => {
                                        console.log("ERROR: sendSignedTransaction() failed for PMT: ", error)
                                    });

                            })
                            .catch(error => {
                                console.log("ERROR: Could not get precompile address: ", error)
                            });

                    })
                    .catch(error => {
                        console.log("ERROR: Could not distribute private transaction: ", error)
                    });

            })
            .catch(error => {
                console.log("ERROR: Could not store payload in tessera: ", error)
            });
    } catch (error) {
        console.log("Caught error :>> ", error);
        return error;
    }
})();