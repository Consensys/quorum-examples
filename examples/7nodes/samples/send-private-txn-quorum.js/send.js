const quorumjs = require("quorum-js");
const Web3 = require("web3");

const web3 = new Web3(
  new Web3.providers.HttpProvider("http://localhost:22000")
);


async function send() {

  const TM1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";
  const TM2_PUBLIC_KEY = ["ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="];

  const simpleStorageDeploy = "0x6060604052341561000f57600080fd5b604051602080610149833981016040528080519060200190919050505b806000819055505b505b610104806100456000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632a1afcd914605157806360fe47b11460775780636d4ce63c146097575b600080fd5b3415605b57600080fd5b606160bd565b6040518082815260200191505060405180910390f35b3415608157600080fd5b6095600480803590602001909190505060c3565b005b341560a157600080fd5b60a760ce565b6040518082815260200191505060405180910390f35b60005481565b806000819055505b50565b6000805490505b905600a165627a7a72305820d5851baab720bba574474de3d09dbeaabc674a15f4dd93b974908476542c23f00029";

  const abi = [{
    constant: true,
    inputs: [],
    name: "storedData",
    outputs: [{
      name: "",
      type: "uint256"
    }],
    payable: false,
    type: "function"
  }, {
    constant: false,
    inputs: [{
      name: "x",
      type: "uint256"
    }],
    name: "set",
    outputs: [],
    payable: false,
    type: "function"
  }, {
    constant: true,
    inputs: [],
    name: "get",
    outputs: [{
      name: "retVal",
      type: "uint256"
    }],
    payable: false,
    type: "function"
  }, {
    inputs: [{
      name: "initVal",
      type: "uint256"
    }],
    payable: false,
    type: "constructor"
  }];

  const simpleContract = new web3.eth.Contract(abi);

  const initializedDeploy = simpleContract
    .deploy({
      data: simpleStorageDeploy,
      arguments: [42]
    })
    .encodeABI();

  const accAddress = "ed9d02e382b34818e88b88a309c7fe71e65f419d";

  const decryptedAccount = web3.eth.accounts.decrypt({
    address: accAddress,
    crypto: {
      cipher: "aes-128-ctr",
      ciphertext: "4e77046ba3f699e744acb4a89c36a3ea1158a1bd90a076d36675f4c883864377",
      cipherparams: {
        iv: "a8932af2a3c0225ee8e872bc0e462c11"
      },
      kdf: "scrypt",
      kdfparams: {
        dklen: 32,
        n: 262144,
        p: 1,
        r: 8,
        salt: "8ca49552b3e92f79c51f2cd3d38dfc723412c212e702bd337a3724e8937aff0f"
      },
      mac: "6d1354fef5aa0418389b1a5d1f5ee0050d7273292a1171c51fd02f9ecff55264"
    },
    id: "a65d1ac3-db7e-445d-a1cc-b6c5eeaa05e0",
    version: 3
  }, "");



  const rtmViaIPC = quorumjs.RawTransactionManager(web3, {
    ipcPath: "/home/vagrant/quorum-examples/7nodes/qdata/c1/tm.ipc"
  });


  const rtmViaAPI = quorumjs.RawTransactionManager(web3, {
    privateUrl: "http://localhost:9081"
  })

  const txnParams = {
    gasPrice: 0,
    gasLimit: 4300000,
    to: "",
    value: 0,
    data: initializedDeploy,
    from: decryptedAccount,
    privateFrom: TM1_PUBLIC_KEY,
    privateFor: TM2_PUBLIC_KEY,
    isPrivate: true
  };


  function promiseDelay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }



  let n = await web3.eth.getTransactionCount("0x" + accAddress);
  txnParams.nonce = n;
  rtmViaIPC.sendRawTransactionViaSendAPI(txnParams)
    .then(function(o, e) {
      console.log("Sending private txn using older API");
      console.log(o, e);
    });

  await promiseDelay(1000);

  n = await web3.eth.getTransactionCount("0x" + accAddress);
  txnParams.nonce = n;
  // Newer API: Quorum v2.2.1+ and Tessera v0.8+
  rtmViaAPI.sendRawTransaction(txnParams)
    .then(function(o, e) {
      console.log("Sending private txn using newer API");
      console.log(o, e);
    });

}


send();
