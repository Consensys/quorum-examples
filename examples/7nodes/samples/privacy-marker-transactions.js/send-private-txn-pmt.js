/*
 * Example of creating a contract, using a privacy marker transaction.
 */

const Web3 = require("web3");
// TODO: this example requires a web3js-quorum release with changes from the pending PR
//  which adds PMT support: https://github.com/ConsenSys/web3js-quorum/pull/25
//  otherwise you need to build webjs-quorum from the PR branch and use:
//      const Web3Quorum = require("/path/to/local/web3js-quorum");
const Web3Quorum = require("web3js-quorum");

const web3 = new Web3Quorum(
  new Web3("http://localhost:22000"),
  {
    privateUrl: "http://localhost:9081",
  },
  true
);

const TM1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";
const TM2_PUBLIC_KEY = "QfeDAys9MPDs2XHExtc84jKGHxZg/aj52DTh0vtA3Xc=";

const ACCOUNT = "0xed9d02e382b34818e88b88a309c7fe71e65f419d";

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
    const txCount = await web3.eth.getTransactionCount(ACCOUNT, "pending");

    // Must use sendGoQuorumTransaction(), as that supports retrieval of private receipt for marker transactions.
    web3.eth.sendGoQuorumTransaction({
      gasPrice: "0x0",
      gasLimit: "4300000",
      value: "0x0",
      data: bytecodeWithInitParam,
      from: ACCOUNT,
      isPrivate: true,
      privateFrom: TM1_PUBLIC_KEY,
      privateFor: [TM2_PUBLIC_KEY],
      nonce: `0x${txCount}`,
    })
    .then(function(receipt) {
      console.log("Got receipt: ", receipt);
    });
  } catch (error) {
    console.log("Caught error :>> ", error);
    return error;
  }
})();
