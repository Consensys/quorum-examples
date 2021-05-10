a = eth.accounts[0]
web3.eth.defaultAccount = a;

// abi and bytecode generated from simplestorage.sol:
// > solcjs --bin --abi simplestorage.sol
var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"inc","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"uint256"}],"name":"IncEvent","type":"event"}];

var bytecode = "0x608060405234801561001057600080fd5b506040516020806101a78339810180604052602081101561003057600080fd5b8101908080519060200190929190505050806000819055505061014f806100586000396000f3fe608060405234801561001057600080fd5b506004361061005e576000357c0100000000000000000000000000000000000000000000000000000000900480632a1afcd9146100635780636d4ce63c14610081578063812600df1461009f575b600080fd5b61006b6100cd565b6040518082815260200191505060405180910390f35b6100896100d3565b6040518082815260200191505060405180910390f35b6100cb600480360360208110156100b557600080fd5b81019080803590602001909291905050506100dc565b005b60005481565b60008054905090565b80600054016000819055507fc13aa85405f3616d514cfd2316b12181b047ed7f229bce08ce53c671f6f94f986000546040518082815260200191505060405180910390a15056fea165627a7a72305820a73dae2a37060d514957796c5d3e8ed77a3b8e0a78f9e351c8290c67c73038190029";

var accContract = web3.eth.contract(abi);
var acc = accContract.new(1, {from:web3.eth.accounts[0], data: bytecode, gas: 0x47b760, privateFor: ["BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=", "R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY=", "UfNSeSGySeKg11DVNEnqrUtxYRVor4+CvluI8tVv62Y="]}, function(e, contract) {
    if (e) {
        console.log("err creating contract", e);
    } else {
        if (!contract.address) {
            console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
        } else {
            console.log("Contract mined! Address: " + contract.address);
            console.log(contract);
        }
    }
});
