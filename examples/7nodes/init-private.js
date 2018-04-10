// shortcut to initialize quicker
//
// // usage A:
// var BLOCKNUMBER = 7; loadScript('init-private.js')
//
// // usage B:
// var BLOCKNUMBER = null; loadScript('init-private.js')


if (BLOCKNUMBER){
        block=BLOCKNUMBER;
        console.log("var BLOCKNUMBER was set to "+BLOCKNUMBER+" = grabbing contract from that block");
}
else {
        block = eth.blockNumber;
        console.log("var BLOCKNUMBER was not set = using newest sealed block " + block);
}

var address=web3.eth.getTransactionReceipt(web3.eth.getBlock(block).transactions[0])["contractAddress"]; // assuming transaction 0 - can fail if there are other transactions in same block
var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"type":"constructor"}];
var private = eth.contract(abi).at(address)

console.log("Done. Initialized 'private' with deployed contract. You can use private.get() and private.set() now.")




